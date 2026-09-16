--[[
    juanita****.club — Ported from App.tsx / index.css

    Every UDim / UDim2 constructor is called directly (no cached aliases)
    so this cannot hit `attempt to call a nil value`.
]]

local Game = game;

local UserInputService = Game : GetService( "UserInputService" );
local TweenService      = Game : GetService( "TweenService" );
local CoreGui           = Game : GetService( "CoreGui" );

-- ── Small helpers that call constructors directly ────────────────────────────

local function Off( N )
    return UDim.new( 0, N );
end;

local function Off2( X, Y )
    return UDim2.new( 0, X or 0, 0, Y or 0 );
end;

local function Create( Class, Properties )
    local Object = Instance.new( Class );

    for Property, Value in pairs( Properties ) do
        Object[ Property ] = Value;
    end;

    return Object;
end;

local function RGB( R, G, B )
    return Color3.fromRGB( R, G, B );
end;

local function Gradient( Object, Stops, Rotation )
    local Points = { };

    for Index, Stop in ipairs( Stops ) do
        Points[ Index ] = ColorSequenceKeypoint.new( Stop[ 1 ], Stop[ 2 ] );
    end;

    return Create( "UIGradient", {
        Color = ColorSequence.new( Points );
        Rotation = Rotation or 90;
        Parent = Object;
    } );
end;

local function Corner( Object, Radius )
    return Create( "UICorner", {
        CornerRadius = UDim.new( 0, Radius );
        Parent = Object;
    } );
end;

local function Stroke( Object, Color, Transparency )
    return Create( "UIStroke", {
        Color = Color;
        Thickness = 1;
        Transparency = Transparency or 0;
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
        Parent = Object;
    } );
end;

-- ── Palette (matches ACCENT / ACCENT_BRIGHT / ACCENT_DIM from App.tsx) ───────

local ACCENT        = RGB( 212, 90, 16 );
local ACCENT_BRIGHT = RGB( 232, 112, 26 );
local ACCENT_DIM    = RGB( 154, 60, 8 );

local TEXT_DEFAULT  = RGB( 160, 160, 160 );
local TEXT_HOVER    = RGB( 184, 184, 184 );
local TEXT_ACTIVE   = RGB( 216, 216, 216 );
local TEXT_PRIMARY  = RGB( 200, 200, 200 );
local TEXT_MUTED    = RGB( 112, 112, 112 );
local TEXT_FAINT    = RGB( 62, 62, 62 );

local BG_WINDOW     = RGB( 22, 22, 22 );
local BG_FOOTER     = RGB( 14, 14, 14 );

local BORDER_SOFT   = RGB( 54, 54, 54 );
local BORDER_HOVER  = RGB( 74, 74, 74 );
local BORDER_FAINT  = RGB( 40, 40, 40 );
local BORDER_EDGE   = RGB( 13, 13, 13 );

local FONT          = Enum.Font.Gotham;
local FONT_MEDIUM   = Enum.Font.GothamMedium;
local FONT_BOLD     = Enum.Font.GothamBold;

local PANEL_WIDTH   = 230;
local RIGHT_WIDTH   = 190;

-- ── Atoms ────────────────────────────────────────────────────────────────────

local function MakeCheckbox( Parent, Text, Default, Callback )
    local State = { Value = Default or false, Hovered = false };

    local Container = Create( "Frame", {
        BackgroundTransparency = 1;
        Size = UDim2.new( 1, 0, 0, 16 );
        Parent = Parent;
    } );

    local Box = Create( "Frame", {
        Size = Off2( 13, 13 );
        Position = Off2( 0, 1 );
        BorderSizePixel = 0;
        Parent = Container;
    } );
    Corner( Box, 2 );

    local BoxGrad = Gradient( Box, {
        { 0, RGB( 32, 32, 32 ) };
        { 1, RGB( 24, 24, 24 ) };
    }, 90 );

    local BoxStroke = Stroke( Box, BORDER_SOFT );

    local Check = Create( "TextLabel", {
        BackgroundTransparency = 1;
        Size = UDim2.new( 1, 0, 1, 0 );
        Text = "✓";
        TextColor3 = Color3.new( 1, 1, 1 );
        TextSize = 11;
        Font = FONT_BOLD;
        TextTransparency = 1;
        Parent = Box;
    } );

    local Label = Create( "TextLabel", {
        BackgroundTransparency = 1;
        Position = Off2( 21, 0 );
        Size = UDim2.new( 1, -21, 1, 0 );
        Text = Text;
        TextColor3 = TEXT_DEFAULT;
        TextSize = 11;
        Font = FONT;
        TextXAlignment = Enum.TextXAlignment.Left;
        Parent = Container;
    } );

    local function Refresh()
        if ( State.Value ) then
            BoxGrad.Color = ColorSequence.new( {
                ColorSequenceKeypoint.new( 0, ACCENT );
                ColorSequenceKeypoint.new( 1, ACCENT_DIM );
            } );
            BoxStroke.Color = ACCENT;
            Check.TextTransparency = 0;
            Label.TextColor3 = TEXT_ACTIVE;
        elseif ( State.Hovered ) then
            BoxGrad.Color = ColorSequence.new( {
                ColorSequenceKeypoint.new( 0, RGB( 37, 37, 37 ) );
                ColorSequenceKeypoint.new( 1, RGB( 28, 28, 28 ) );
            } );
            BoxStroke.Color = BORDER_HOVER;
            Check.TextTransparency = 1;
            Label.TextColor3 = TEXT_HOVER;
        else
            BoxGrad.Color = ColorSequence.new( {
                ColorSequenceKeypoint.new( 0, RGB( 32, 32, 32 ) );
                ColorSequenceKeypoint.new( 1, RGB( 24, 24, 24 ) );
            } );
            BoxStroke.Color = BORDER_SOFT;
            Check.TextTransparency = 1;
            Label.TextColor3 = TEXT_DEFAULT;
        end;
    end;

    Container.InputBegan : Connect( function( Input )
        if ( Input.UserInputType ~= Enum.UserInputType.MouseButton1 ) then
            return;
        end;

        State.Value = not State.Value;
        Refresh();

        if ( Callback ) then
            Callback( State.Value );
        end;
    end );

    Container.MouseEnter : Connect( function() State.Hovered = true; Refresh(); end );
    Container.MouseLeave : Connect( function() State.Hovered = false; Refresh(); end );

    Refresh();

    return {
        Container = Container;
        Set = function( Value ) State.Value = Value; Refresh(); end;
        Get = function() return State.Value; end;
    };
end;

local function MakeSlider( Parent, LabelText, Default, Callback )
    local State = { Value = Default or 50, Dragging = false };

    local Container = Create( "Frame", {
        BackgroundTransparency = 1;
        Size = UDim2.new( 1, 0, 0, 24 );
        Parent = Parent;
    } );

    local LabelRow = Create( "Frame", {
        BackgroundTransparency = 1;
        Size = UDim2.new( 1, 0, 0, 14 );
        Parent = Container;
    } );

    Create( "TextLabel", {
        BackgroundTransparency = 1;
        Size = UDim2.new( 1, 0, 1, 0 );
        Text = LabelText;
        TextColor3 = TEXT_DEFAULT;
        TextSize = 11;
        Font = FONT;
        TextXAlignment = Enum.TextXAlignment.Left;
        Parent = LabelRow;
    } );

    local ValueLabel = Create( "TextLabel", {
        BackgroundTransparency = 1;
        Size = UDim2.new( 1, 0, 1, 0 );
        Text = tostring( State.Value ) .. "%";
        TextColor3 = ACCENT_BRIGHT;
        TextSize = 11;
        Font = FONT_BOLD;
        TextXAlignment = Enum.TextXAlignment.Right;
        Parent = LabelRow;
    } );

    local Track = Create( "TextButton", {
        BackgroundColor3 = RGB( 16, 16, 16 );
        BorderSizePixel = 0;
        Position = Off2( 0, 16 );
        Size = UDim2.new( 1, 0, 0, 5 );
        Text = "";
        AutoButtonColor = false;
        Parent = Container;
    } );
    Corner( Track, 3 );
    Gradient( Track, {
        { 0, RGB( 16, 16, 16 ) };
        { 1, RGB( 26, 26, 26 ) };
    }, 90 );
    Stroke( Track, RGB( 46, 46, 46 ) );

    local Fill = Create( "Frame", {
        BackgroundColor3 = ACCENT;
        BorderSizePixel = 0;
        Size = UDim2.new( State.Value / 100, 0, 1, 0 );
        Parent = Track;
    } );
    Corner( Fill, 3 );
    Gradient( Fill, {
        { 0, ACCENT_DIM };
        { 1, ACCENT_BRIGHT };
    }, 0 );

    local Thumb = Create( "Frame", {
        BackgroundColor3 = RGB( 224, 224, 224 );
        BorderSizePixel = 0;
        AnchorPoint = Vector2.new( 0.5, 0.5 );
        Position = UDim2.new( State.Value / 100, 0, 0.5, 0 );
        Size = Off2( 9, 9 );
        ZIndex = 2;
        Parent = Track;
    } );
    Corner( Thumb, 100 );
    Gradient( Thumb, {
        { 0, RGB( 224, 224, 224 ) };
        { 1, RGB( 176, 176, 176 ) };
    }, 90 );
    Stroke( Thumb, ACCENT );

    local function Refresh()
        local Percent = State.Value / 100;
        Fill.Size = UDim2.new( Percent, 0, 1, 0 );
        Thumb.Position = UDim2.new( Percent, 0, 0.5, 0 );
        ValueLabel.Text = tostring( State.Value ) .. "%";
    end;

    local function FromMouse( MouseX )
        local Percent = math.clamp( ( MouseX - Track.AbsolutePosition.X ) / Track.AbsoluteSize.X, 0, 1 );
        State.Value = math.floor( Percent * 100 );

        Refresh();

        if ( Callback ) then
            Callback( State.Value );
        end;
    end;

    Track.InputBegan : Connect( function( Input )
        if ( Input.UserInputType ~= Enum.UserInputType.MouseButton1 ) then
            return;
        end;

        State.Dragging = true;
        FromMouse( Input.Position.X );
    end );

    UserInputService.InputChanged : Connect( function( Input )
        if ( State.Dragging ) and ( Input.UserInputType == Enum.UserInputType.MouseMovement ) then
            FromMouse( Input.Position.X );
        end;
    end );

    UserInputService.InputEnded : Connect( function( Input )
        if ( Input.UserInputType == Enum.UserInputType.MouseButton1 ) then
            State.Dragging = false;
        end;
    end );

    Refresh();

    return {
        Container = Container;
        Set = function( Value ) State.Value = Value; Refresh(); end;
        Get = function() return State.Value; end;
    };
end;

local function MakeDropdown( Parent, Options, Default, Callback )
    local State = { Value = Default or Options[ 1 ] or "", Open = false, Hovered = nil };

    local Container = Create( "Frame", {
        BackgroundTransparency = 1;
        Size = UDim2.new( 1, 0, 0, 20 );
        ZIndex = 3;
        Parent = Parent;
    } );

    local Trigger = Create( "TextButton", {
        BorderSizePixel = 0;
        Size = UDim2.new( 1, 0, 1, 0 );
        Text = "";
        AutoButtonColor = false;
        Parent = Container;
    } );
    Corner( Trigger, 3 );
    Stroke( Trigger, RGB( 58, 58, 58 ) );

    local TriggerGrad = Gradient( Trigger, {
        { 0, RGB( 35, 35, 35 ) };
        { 1, RGB( 26, 26, 26 ) };
    }, 90 );

    local TriggerText = Create( "TextLabel", {
        BackgroundTransparency = 1;
        Position = Off2( 8, 0 );
        Size = UDim2.new( 1, -20, 1, 0 );
        Text = State.Value;
        TextColor3 = TEXT_PRIMARY;
        TextSize = 11;
        Font = FONT;
        TextXAlignment = Enum.TextXAlignment.Left;
        Parent = Trigger;
    } );

    Create( "TextLabel", {
        BackgroundTransparency = 1;
        Position = UDim2.new( 1, -14, 0, 0 );
        Size = Off2( 10, 20 );
        Text = "v";
        TextColor3 = RGB( 136, 136, 136 );
        TextSize = 10;
        Font = FONT_BOLD;
        Parent = Trigger;
    } );

    local List = Create( "Frame", {
        BackgroundColor3 = RGB( 30, 30, 30 );
        BorderSizePixel = 0;
        Position = Off2( 0, 20 );
        Size = UDim2.new( 1, 0, 0, 0 );
        ClipsDescendants = true;
        Visible = false;
        ZIndex = 5;
        Parent = Container;
    } );
    Corner( List, 3 );
    Stroke( List, ACCENT );

    Create( "UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = List;
    } );

    local Rows = { };

    for Index, Option in ipairs( Options ) do
        local Row = Create( "TextButton", {
            BackgroundTransparency = 1;
            Size = UDim2.new( 1, 0, 0, 20 );
            Text = "";
            AutoButtonColor = false;
            LayoutOrder = Index;
            Parent = List;
        } );

        local RowAccent = Create( "Frame", {
            BackgroundColor3 = ACCENT;
            BorderSizePixel = 0;
            Size = Off2( 2, 20 );
            Visible = false;
            Parent = Row;
        } );

        local RowText = Create( "TextLabel", {
            BackgroundTransparency = 1;
            Position = Off2( 8, 0 );
            Size = UDim2.new( 1, -8, 1, 0 );
            Text = Option;
            TextColor3 = RGB( 184, 184, 184 );
            TextSize = 11;
            Font = FONT;
            TextXAlignment = Enum.TextXAlignment.Left;
            Parent = Row;
        } );

        Rows[ Option ] = { Text = RowText, Accent = RowAccent };

        Row.InputBegan : Connect( function( Input )
            if ( Input.UserInputType ~= Enum.UserInputType.MouseButton1 ) then
                return;
            end;

            State.Value = Option;
            TriggerText.Text = Option;

            if ( Callback ) then
                Callback( Option );
            end;

            State.Open = false;
            Refresh();
        end );

        Row.MouseEnter : Connect( function() State.Hovered = Option; Refresh(); end );
        Row.MouseLeave : Connect( function() State.Hovered = nil; Refresh(); end );
    end;

    local function Refresh()
        if ( State.Open ) then
            TriggerGrad.Color = ColorSequence.new( {
                ColorSequenceKeypoint.new( 0, RGB( 40, 40, 40 ) );
                ColorSequenceKeypoint.new( 1, RGB( 30, 30, 30 ) );
            } );
        else
            TriggerGrad.Color = ColorSequence.new( {
                ColorSequenceKeypoint.new( 0, RGB( 35, 35, 35 ) );
                ColorSequenceKeypoint.new( 1, RGB( 26, 26, 26 ) );
            } );
        end;

        for Option, Entry in pairs( Rows ) do
            if ( Option == State.Value ) then
                Entry.Text.TextColor3 = ACCENT_BRIGHT;
                Entry.Text.Font = FONT_BOLD;
                Entry.Accent.Visible = false;
            elseif ( Option == State.Hovered ) then
                Entry.Text.TextColor3 = RGB( 221, 221, 221 );
                Entry.Text.Font = FONT;
                Entry.Accent.Visible = true;
            else
                Entry.Text.TextColor3 = RGB( 184, 184, 184 );
                Entry.Text.Font = FONT;
                Entry.Accent.Visible = false;
            end;
        end;

        TweenService : Create( List, TweenInfo.new( 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out ), {
            Size = State.Open and UDim2.new( 1, 0, 0, #Options * 20 ) or UDim2.new( 1, 0, 0, 0 );
        } ) : Play();

        List.Visible = State.Open or List.Size.Y.Offset > 0;
    end;

    Trigger.MouseButton1Click : Connect( function()
        State.Open = not State.Open;
        Refresh();
    end );

    Refresh();

    return {
        Container = Container;
        Set = function( Value ) State.Value = Value; TriggerText.Text = Value; Refresh(); end;
        Get = function() return State.Value; end;
    };
end;

local function MakeDivider( Parent )
    local Divider = Create( "Frame", {
        BackgroundColor3 = RGB( 44, 44, 44 );
        BorderSizePixel = 0;
        Size = UDim2.new( 1, 0, 0, 1 );
        Parent = Parent;
    } );
    Gradient( Divider, {
        { 0, RGB( 22, 22, 22 ) };
        { 0.2, RGB( 44, 44, 44 ) };
        { 0.5, RGB( 56, 56, 56 ) };
        { 0.8, RGB( 44, 44, 44 ) };
        { 1, RGB( 22, 22, 22 ) };
    }, 0 );

    return Divider;
end;

local function MakeSectionLabel( Parent, Text )
    return Create( "TextLabel", {
        BackgroundTransparency = 1;
        Size = UDim2.new( 1, 0, 0, 12 );
        Text = string.upper( Text );
        TextColor3 = RGB( 120, 120, 120 );
        TextSize = 10;
        Font = FONT;
        TextXAlignment = Enum.TextXAlignment.Left;
        Parent = Parent;
    } );
end;

local function MakePanelHeading( Parent, Text )
    local Container = Create( "Frame", {
        BackgroundTransparency = 1;
        Size = UDim2.new( 1, 0, 0, 16 );
        Parent = Parent;
    } );

    local Bar = Create( "Frame", {
        BackgroundColor3 = ACCENT_BRIGHT;
        BorderSizePixel = 0;
        Position = Off2( 0, 2 );
        Size = Off2( 3, 11 );
        Parent = Container;
    } );
    Corner( Bar, 1 );
    Gradient( Bar, {
        { 0, ACCENT_BRIGHT };
        { 1, ACCENT_DIM };
    }, 90 );

    Create( "TextLabel", {
        BackgroundTransparency = 1;
        Position = Off2( 8, 0 );
        Size = UDim2.new( 1, -8, 1, 0 );
        Text = Text;
        TextColor3 = TEXT_PRIMARY;
        TextSize = 11;
        Font = FONT_BOLD;
        TextXAlignment = Enum.TextXAlignment.Left;
        Parent = Container;
    } );

    return Container;
end;

local function MakeTab( Parent, Text, Small, LayoutOrder, OnClick )
    local State = { Active = false, Hovered = false };

    local Tab = Create( "TextButton", {
        BorderSizePixel = 0;
        Size = Off2( 60, Small and 22 or 24 );
        Text = "";
        AutoButtonColor = false;
        LayoutOrder = LayoutOrder or 0;
        Parent = Parent;
    } );

    local Fill = Create( "Frame", {
        BackgroundTransparency = 1;
        Size = UDim2.new( 1, 0, 1, 0 );
        Parent = Tab;
    } );
    local FillGrad = Gradient( Fill, {
        { 0, RGB( 28, 28, 28 ) };
        { 1, RGB( 20, 20, 20 ) };
    }, 90 );

    local Label = Create( "TextLabel", {
        BackgroundTransparency = 1;
        Size = UDim2.new( 1, 0, 1, 0 );
        Text = Text;
        TextColor3 = TEXT_MUTED;
        TextSize = Small and 10 or 11;
        Font = FONT;
        Parent = Tab;
    } );

    local TopBorder = Create( "Frame", {
        BackgroundColor3 = BORDER_FAINT;
        BorderSizePixel = 0;
        Size = UDim2.new( 1, 0, 0, 1 );
        Parent = Tab;
    } );

    -- The bottom "connect" tail — when active, this 1px frame reaches below
    -- the tab and covers the panel divider, matching marginBottom: -1 in TSX.
    local Tail = Create( "Frame", {
        BackgroundColor3 = RGB( 32, 32, 32 );
        BorderSizePixel = 0;
        Position = UDim2.new( 0, 0, 1, 0 );
        Size = UDim2.new( 1, 0, 0, 1 );
        Visible = false;
        ZIndex = 5;
        Parent = Tab;
    } );

    local function Refresh()
        local Padding = Small and 18 or 24;
        Tab.Size = Off2( Label.TextBounds.X + Padding, Small and 22 or 24 );

        if ( State.Active ) then
            Fill.BackgroundTransparency = 1;
            FillGrad.Color = ColorSequence.new( {
                ColorSequenceKeypoint.new( 0, RGB( 42, 42, 42 ) );
                ColorSequenceKeypoint.new( 0.6, RGB( 32, 32, 32 ) );
                ColorSequenceKeypoint.new( 1, RGB( 28, 28, 28 ) );
            } );
            Label.TextColor3 = RGB( 224, 224, 224 );
            Label.Font = FONT_BOLD;
            TopBorder.BackgroundColor3 = ACCENT;
            Tail.Visible = true;
            Tab.ZIndex = 3;
        elseif ( State.Hovered ) then
            Fill.BackgroundTransparency = 0;
            FillGrad.Color = ColorSequence.new( {
                ColorSequenceKeypoint.new( 0, RGB( 34, 34, 34 ) );
                ColorSequenceKeypoint.new( 1, RGB( 26, 26, 26 ) );
            } );
            Label.TextColor3 = TEXT_HOVER;
            Label.Font = FONT;
            TopBorder.BackgroundColor3 = RGB( 64, 64, 64 );
            Tail.Visible = false;
            Tab.ZIndex = 1;
        else
            Fill.BackgroundTransparency = 0;
            FillGrad.Color = ColorSequence.new( {
                ColorSequenceKeypoint.new( 0, RGB( 28, 28, 28 ) );
                ColorSequenceKeypoint.new( 1, RGB( 20, 20, 20 ) );
            } );
            Label.TextColor3 = TEXT_MUTED;
            Label.Font = FONT;
            TopBorder.BackgroundColor3 = BORDER_FAINT;
            Tail.Visible = false;
            Tab.ZIndex = 1;
        end;
    end;

    Tab.MouseButton1Click : Connect( function()
        if ( OnClick ) then OnClick(); end;
    end );

    Tab.MouseEnter : Connect( function() State.Hovered = true; Refresh(); end );
    Tab.MouseLeave : Connect( function() State.Hovered = false; Refresh(); end );

    Refresh();
    task.defer( Refresh );

    return {
        Tab = Tab;
        SetActive = function( Value ) State.Active = Value; Refresh(); end;
    };
end;

-- ── Page (wrapper around a Frame) ────────────────────────────────────────────

local Page = { };
Page.__index = Page;

local function NewPage( Frame )
    return setmetatable( { Frame = Frame }, Page );
end;

function Page : Checkbox( Label, Default, Callback )
    return MakeCheckbox( self.Frame, Label, Default, Callback );
end;

function Page : Slider( Label, Default, Callback )
    return MakeSlider( self.Frame, Label, Default, Callback );
end;

function Page : Dropdown( Options, Default, Callback )
    return MakeDropdown( self.Frame, Options, Default, Callback );
end;

function Page : Divider()
    return MakeDivider( self.Frame );
end;

function Page : Label( Text )
    return MakeSectionLabel( self.Frame, Text );
end;

-- ── Interface ────────────────────────────────────────────────────────────────

local Interface = { };
Interface.__index = Interface;

function Interface.new( Title )
    Title = Title or "juanita****.club";

    local ScreenGui = Create( "ScreenGui", {
        Name = "juanita_club";
        ResetOnSpawn = false;
        IgnoreGuiInset = true;
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
        Parent = CoreGui;
    } );

    -- Window
    local Window = Create( "Frame", {
        BackgroundColor3 = BG_WINDOW;
        BorderSizePixel = 0;
        AnchorPoint = Vector2.new( 0.5, 0.5 );
        Position = UDim2.new( 0.5, 0, 0.5, 0 );
        Size = Off2( 420, 380 );
        ClipsDescendants = true;
        Parent = ScreenGui;
    } );
    Corner( Window, 4 );
    Stroke( Window, BORDER_EDGE );

    -- Title bar
    local TitleBar = Create( "Frame", {
        BorderSizePixel = 0;
        Size = UDim2.new( 1, 0, 0, 26 );
        Parent = Window;
    } );
    Gradient( TitleBar, {
        { 0, RGB( 42, 42, 42 ) };
        { 0.5, RGB( 31, 31, 31 ) };
        { 1, RGB( 26, 26, 26 ) };
    }, 90 );

    Create( "Frame", {
        BackgroundColor3 = RGB( 10, 10, 10 );
        BorderSizePixel = 0;
        Size = UDim2.new( 1, 0, 0, 1 );
        Position = UDim2.new( 0, 0, 1, -1 );
        Parent = TitleBar;
    } );

    local BrandMark = Create( "Frame", {
        BackgroundColor3 = ACCENT_BRIGHT;
        BorderSizePixel = 0;
        Position = Off2( 10, 7 );
        Size = Off2( 10, 12 );
        Parent = TitleBar;
    } );
    Corner( BrandMark, 2 );
    Gradient( BrandMark, {
        { 0, ACCENT_BRIGHT };
        { 1, ACCENT_DIM };
    }, 90 );

    Create( "TextLabel", {
        BackgroundTransparency = 1;
        Position = Off2( 24, 0 );
        Size = UDim2.new( 1, -90, 1, 0 );
        Text = Title;
        TextColor3 = TEXT_PRIMARY;
        TextSize = 11;
        Font = FONT_MEDIUM;
        TextXAlignment = Enum.TextXAlignment.Left;
        Parent = TitleBar;
    } );

    local TitleButtons = Create( "Frame", {
        BackgroundTransparency = 1;
        Position = UDim2.new( 1, -42, 0, 6 );
        Size = Off2( 38, 14 );
        Parent = TitleBar;
    } );

    local MinBtn = Create( "TextButton", {
        BackgroundColor3 = RGB( 46, 46, 46 );
        BorderSizePixel = 0;
        Size = Off2( 18, 14 );
        Text = "-";
        TextColor3 = RGB( 144, 144, 144 );
        TextSize = 11;
        Font = FONT;
        AutoButtonColor = false;
        Parent = TitleButtons;
    } );
    Corner( MinBtn, 2 );
    Stroke( MinBtn, RGB( 72, 72, 72 ) );

    local CloseBtn = Create( "TextButton", {
        BackgroundColor3 = RGB( 146, 32, 32 );
        BorderSizePixel = 0;
        Position = Off2( 21, 0 );
        Size = Off2( 18, 14 );
        Text = "x";
        TextColor3 = RGB( 238, 238, 238 );
        TextSize = 10;
        Font = FONT;
        AutoButtonColor = false;
        Parent = TitleButtons;
    } );
    Corner( CloseBtn, 2 );
    Stroke( CloseBtn, RGB( 106, 16, 16 ) );

    -- Main tab strip
    local TabStrip = Create( "Frame", {
        BorderSizePixel = 0;
        Position = Off2( 0, 26 );
        Size = UDim2.new( 1, 0, 0, 28 );
        Parent = Window;
    } );
    Gradient( TabStrip, {
        { 0, RGB( 22, 22, 22 ) };
        { 1, RGB( 18, 18, 18 ) };
    }, 90 );

    -- The border that active tabs "merge" into
    local StripBorder = Create( "Frame", {
        BackgroundColor3 = RGB( 46, 46, 46 );
        BorderSizePixel = 0;
        Size = UDim2.new( 1, 0, 0, 1 );
        Position = UDim2.new( 0, 0, 1, -1 );
        Parent = TabStrip;
    } );

    local TabHolder = Create( "Frame", {
        BackgroundTransparency = 1;
        Position = Off2( 6, 4 );
        Size = UDim2.new( 1, -12, 1, -4 );
        Parent = TabStrip;
    } );

    Create( "UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Padding = Off( 2 );
        VerticalAlignment = Enum.VerticalAlignment.Bottom;
        Parent = TabHolder;
    } );

    -- Body
    local Body = Create( "Frame", {
        BackgroundColor3 = BG_WINDOW;
        BorderSizePixel = 0;
        Position = Off2( 0, 54 );
        Size = UDim2.new( 1, 0, 0, 300 );
        Parent = Window;
    } );

    local LeftPanel = Create( "Frame", {
        BackgroundColor3 = BG_WINDOW;
        BorderSizePixel = 0;
        Size = Off2( PANEL_WIDTH, 300 );
        Parent = Body;
    } );

    local LeftInner = Create( "Frame", {
        BackgroundTransparency = 1;
        Position = Off2( 12, 10 );
        Size = Off2( PANEL_WIDTH - 24, 0 );
        AutomaticSize = Enum.AutomaticSize.Y;
        Parent = LeftPanel;
    } );

    Create( "UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder;
        Padding = Off( 0 );
        Parent = LeftInner;
    } );

    Create( "Frame", {
        BackgroundColor3 = RGB( 32, 32, 32 );
        BorderSizePixel = 0;
        Position = Off2( PANEL_WIDTH, 0 );
        Size = Off2( 1, 300 );
        Parent = Body;
    } );

    local RightPanel = Create( "Frame", {
        BackgroundColor3 = BG_WINDOW;
        BorderSizePixel = 0;
        Position = Off2( PANEL_WIDTH + 1, 0 );
        Size = Off2( RIGHT_WIDTH, 300 );
        Parent = Body;
    } );

    local RightInner = Create( "Frame", {
        BackgroundTransparency = 1;
        Position = Off2( 10, 8 );
        Size = Off2( RIGHT_WIDTH - 20, 0 );
        AutomaticSize = Enum.AutomaticSize.Y;
        Parent = RightPanel;
    } );

    -- Right sub-tab strip
    local RightStrip = Create( "Frame", {
        BackgroundTransparency = 1;
        Size = Off2( RIGHT_WIDTH - 20, 22 );
        Parent = RightInner;
    } );

    Create( "Frame", {
        BackgroundColor3 = RGB( 46, 46, 46 );
        BorderSizePixel = 0;
        Size = UDim2.new( 1, 0, 0, 1 );
        Position = UDim2.new( 0, 0, 1, -1 );
        Parent = RightStrip;
    } );

    Create( "UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Padding = Off( 1 );
        VerticalAlignment = Enum.VerticalAlignment.Bottom;
        Parent = RightStrip;
    } );

    -- Footer
    local Footer = Create( "Frame", {
        BorderSizePixel = 0;
        Position = UDim2.new( 0, 0, 1, -20 );
        Size = UDim2.new( 1, 0, 0, 20 );
        Parent = Window;
    } );
    Gradient( Footer, {
        { 0, RGB( 18, 18, 18 ) };
        { 1, RGB( 14, 14, 14 ) };
    }, 90 );

    Create( "Frame", {
        BackgroundColor3 = RGB( 30, 30, 30 );
        BorderSizePixel = 0;
        Size = UDim2.new( 1, 0, 0, 1 );
        Parent = Footer;
    } );

    Create( "TextLabel", {
        BackgroundTransparency = 1;
        Position = Off2( 10, 0 );
        Size = UDim2.new( 1, -20, 1, 0 );
        Text = "build 2.4.1";
        TextColor3 = TEXT_FAINT;
        TextSize = 9;
        Font = FONT;
        TextXAlignment = Enum.TextXAlignment.Left;
        Parent = Footer;
    } );

    local StatusDot = Create( "Frame", {
        BackgroundColor3 = RGB( 46, 204, 85 );
        BorderSizePixel = 0;
        AnchorPoint = Vector2.new( 1, 0.5 );
        Position = UDim2.new( 1, -50, 0.5, 0 );
        Size = Off2( 5, 5 );
        Parent = Footer;
    } );
    Corner( StatusDot, 100 );

    Create( "TextLabel", {
        BackgroundTransparency = 1;
        AnchorPoint = Vector2.new( 1, 0.5 );
        Position = UDim2.new( 1, -10, 0.5, 0 );
        Size = Off2( 36, 12 );
        Text = "CONNECTED";
        TextColor3 = TEXT_FAINT;
        TextSize = 9;
        Font = FONT;
        TextXAlignment = Enum.TextXAlignment.Right;
        Parent = Footer;
    } );

    -- Drag
    local Dragging = false;
    local DragStartMouse = Vector2.new( 0, 0 );
    local DragStartPos = UDim2.new( 0, 0, 0, 0 );

    TitleBar.InputBegan : Connect( function( Input )
        if ( Input.UserInputType ~= Enum.UserInputType.MouseButton1 ) then return; end;

        Dragging = true;
        DragStartMouse = Vector2.new( Input.Position.X, Input.Position.Y );
        DragStartPos = Window.Position;
    end );

    UserInputService.InputChanged : Connect( function( Input )
        if ( not Dragging ) then return; end;
        if ( Input.UserInputType ~= Enum.UserInputType.MouseMovement ) then return; end;

        Window.Position = UDim2.new(
            DragStartPos.X.Scale, DragStartPos.X.Offset + ( Input.Position.X - DragStartMouse.X ),
            DragStartPos.Y.Scale, DragStartPos.Y.Offset + ( Input.Position.Y - DragStartMouse.Y )
        );
    end );

    UserInputService.InputEnded : Connect( function( Input )
        if ( Input.UserInputType == Enum.UserInputType.MouseButton1 ) then
            Dragging = false;
        end;
    end );

    CloseBtn.MouseButton1Click : Connect( function() ScreenGui : Destroy(); end );
    MinBtn.MouseButton1Click : Connect( function() Window.Visible = not Window.Visible; end );

    -- Tab state
    local LeftPages = { };
    local LeftTabs = { };
    local RightPages = { };
    local RightTabs = { };

    local API = setmetatable( {
        ScreenGui = ScreenGui;
        Window = Window;
        RightStrip = RightStrip;
        LeftPages = LeftPages;
        RightPages = RightPages;
        Heading = nil;
    }, Interface );

    function API : AddLeftTab( Name )
        if ( LeftPages[ Name ] ) then
            return LeftPages[ Name ];
        end;

        local Frame = Create( "Frame", {
            BackgroundTransparency = 1;
            Size = Off2( PANEL_WIDTH - 24, 0 );
            AutomaticSize = Enum.AutomaticSize.Y;
            LayoutOrder = 1;
            Visible = false;
            Parent = LeftInner;
        } );

        Create( "UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder;
            Padding = Off( 5 );
            Parent = Frame;
        } );

        local TabAPI = MakeTab( TabHolder, Name, false, #LeftPages + 1, function()
            API : SelectLeftTab( Name );
        end );

        local Wrapped = NewPage( Frame );
        LeftPages[ Name ] = Wrapped;
        LeftTabs[ Name ] = TabAPI;

        return Wrapped;
    end;

    function API : SelectLeftTab( Name )
        for TabName, Wrapped in pairs( LeftPages ) do
            Wrapped.Frame.Visible = ( TabName == Name );
        end;

        for TabName, TabAPI in pairs( LeftTabs ) do
            TabAPI : SetActive( TabName == Name );
        end;

        if ( API.Heading ) then
            API.Heading : Destroy();
        end;

        local Holder = Create( "Frame", {
            BackgroundTransparency = 1;
            Size = UDim2.new( 1, 0, 0, 22 );
            LayoutOrder = 0;
            Parent = LeftInner;
        } );

        API.Heading = MakePanelHeading( Holder, Name );
        API.Heading.Size = UDim2.new( 1, 0, 1, 0 );
    end;

    function API : AddRightTab( Name )
        if ( RightPages[ Name ] ) then
            return RightPages[ Name ];
        end;

        local Frame = Create( "Frame", {
            BackgroundTransparency = 1;
            Position = Off2( 0, 30 );
            Size = Off2( RIGHT_WIDTH - 20, 0 );
            AutomaticSize = Enum.AutomaticSize.Y;
            Visible = false;
            Parent = RightInner;
        } );

        Create( "UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder;
            Padding = Off( 5 );
            Parent = Frame;
        } );

        local TabAPI = MakeTab( RightStrip, Name, true, #RightPages + 1, function()
            API : SelectRightTab( Name );
        end );

        local Wrapped = NewPage( Frame );
        RightPages[ Name ] = Wrapped;
        RightTabs[ Name ] = TabAPI;

        return Wrapped;
    end;

    function API : SelectRightTab( Name )
        for TabName, Wrapped in pairs( RightPages ) do
            Wrapped.Frame.Visible = ( TabName == Name );
        end;

        for TabName, TabAPI in pairs( RightTabs ) do
            TabAPI : SetActive( TabName == Name );
        end;
    end;

    -- Fit window to tallest tab
    task.defer( function()
        task.wait( 0.1 );

        local MaxHeight = 260;

        for _, Wrapped in pairs( LeftPages ) do
            MaxHeight = math.max( MaxHeight, Wrapped.Frame.AbsoluteSize.Y + 40 );
        end;

        for _, Wrapped in pairs( RightPages ) do
            MaxHeight = math.max( MaxHeight, Wrapped.Frame.AbsoluteSize.Y + 60 );
        end;

        Body.Size = UDim2.new( 1, 0, 0, MaxHeight );
        LeftPanel.Size = Off2( PANEL_WIDTH, MaxHeight );
        RightPanel.Size = Off2( RIGHT_WIDTH, MaxHeight );

        Window.Size = Off2( 420, 26 + 28 + MaxHeight + 20 );
    end );

    return API;
end;

return Interface;
