--[[
    juanita****.club — Ported from App.tsx / index.css

    Visual fidelity notes:
      - CSS box-shadow: inset  → 1px dark Frame at top of surface
      - CSS box-shadow: 0 0 Npx accent  → UIStroke with high Transparency
      - CSS radial-gradient  → solid BG + transparent ScreenGui
      - CSS linear-gradient  → UIGradient (Rotation 90 = top→bottom)
      - CSS flex gap  → UIListLayout.Padding
]]

local Game = game;

-- Services
local UserInputService = Game : GetService( "UserInputService" );
local TweenService      = Game : GetService( "TweenService" );
local CoreGui           = Game : GetService( "CoreGui" );

-- Cache
local InstanceNew             = Instance.new;
local TweenInfoNew            = TweenInfo.new;
local Color3New               = Color3.new;
local Color3FromRGB           = Color3.fromRGB;
local UDim2New                = UDim2.new;
local UDim2FromOffset         = UDim2.fromOffset;
local UDimFromOffset          = UDim.fromOffset;
local Vector2New              = Vector2.new;
local ColorSequenceNew        = ColorSequence.new;
local ColorSequenceKeypointNew = ColorSequenceKeypoint.new;

-- Palette
const ACCENT        = Color3FromRGB( 212, 90, 16 );
const ACCENT_BRIGHT = Color3FromRGB( 232, 112, 26 );
const ACCENT_DIM    = Color3FromRGB( 154, 60, 8 );

const TEXT_DEFAULT  = Color3FromRGB( 160, 160, 160 );
const TEXT_HOVER    = Color3FromRGB( 184, 184, 184 );
const TEXT_ACTIVE   = Color3FromRGB( 216, 216, 216 );
const TEXT_PRIMARY  = Color3FromRGB( 200, 200, 200 );
const TEXT_MUTED    = Color3FromRGB( 112, 112, 112 );
const TEXT_FAINT    = Color3FromRGB( 62, 62, 62 );

const SURFACE_TOP   = Color3FromRGB( 37, 37, 37 );
const SURFACE_BOT   = Color3FromRGB( 24, 24, 24 );
const SURFACE_HOVER = Color3FromRGB( 45, 45, 45 );

const BG_WINDOW     = Color3FromRGB( 22, 22, 22 );
const BG_FOOTER     = Color3FromRGB( 14, 14, 14 );
const BG_DEEP       = Color3FromRGB( 16, 16, 16 );

const BORDER_SOFT   = Color3FromRGB( 54, 54, 54 );
const BORDER_HOVER  = Color3FromRGB( 74, 74, 74 );
const BORDER_FAINT  = Color3FromRGB( 40, 40, 40 );
const BORDER_EDGE   = Color3FromRGB( 13, 13, 13 );

const FONT          = Enum.Font.Gotham;
const FONT_MEDIUM   = Enum.Font.GothamMedium;
const FONT_BOLD     = Enum.Font.GothamBold;

-- ── Utilities ─────────────────────────────────────────────────────────────────

local function Create( Class, Properties )
    local Object = InstanceNew( Class );

    for Property, Value in pairs( Properties ) do
        Object[ Property ] = Value;
    end;

    return Object;
end;

local function ApplyGradient( Object, Stops, Rotation )
    local Points = { };

    for Index, Stop in ipairs( Stops ) do
        Points[ Index ] = ColorSequenceKeypointNew( Stop[ 1 ], Stop[ 2 ] );
    end;

    return Create( "UIGradient", {
        Color = ColorSequenceNew( Points );
        Rotation = Rotation or 90;
        Parent = Object;
    } );
end;

local function ApplyCorner( Object, Radius )
    return Create( "UICorner", {
        CornerRadius = UDimFromOffset( Radius );
        Parent = Object;
    } );
end;

local function ApplyStroke( Object, Color, Thickness, Transparency )
    return Create( "UIStroke", {
        Color = Color;
        Thickness = Thickness or 1;
        Transparency = Transparency or 0;
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
        Parent = Object;
    } );
end;

-- ── Atoms ─────────────────────────────────────────────────────────────────────

local function MakeCheckbox( Parent, Text, Default, Callback )
    local State = { Value = Default or false, Hovered = false };

    const Container = Create( "Frame", {
        BackgroundTransparency = 1;
        Size = UDim2New( 1, 0, 0, 16 );
        Parent = Parent;
    } );

    const Box = Create( "Frame", {
        Size = UDim2FromOffset( 13, 13 );
        Position = UDim2FromOffset( 0, 1 );
        BackgroundColor3 = Color3FromRGB( 32, 32, 32 );
        BorderSizePixel = 0;
        Parent = Container;
    } );
    ApplyCorner( Box, 2 );

    const BoxGrad = ApplyGradient( Box, {
        { 0, Color3FromRGB( 32, 32, 32 ) };
        { 1, Color3FromRGB( 24, 24, 24 ) };
    }, 90 );

    const BoxStroke = ApplyStroke( Box, BORDER_SOFT, 1, 0 );

    const Check = Create( "TextLabel", {
        BackgroundTransparency = 1;
        Size = UDim2New( 1, 0, 1, 0 );
        Text = "✓";
        TextColor3 = Color3New( 1, 1, 1 );
        TextSize = 11;
        Font = FONT_BOLD;
        TextTransparency = 1;
        Parent = Box;
    } );

    const Label = Create( "TextLabel", {
        BackgroundTransparency = 1;
        Position = UDim2FromOffset( 21, 0 );
        Size = UDim2New( 1, -21, 1, 0 );
        Text = Text;
        TextColor3 = TEXT_DEFAULT;
        TextSize = 11;
        Font = FONT;
        TextXAlignment = Enum.TextXAlignment.Left;
        Parent = Container;
    } );

    local function Refresh()
        if ( State.Value ) then
            BoxGrad.Color = ColorSequenceNew( {
                ColorSequenceKeypointNew( 0, ACCENT );
                ColorSequenceKeypointNew( 1, ACCENT_DIM );
            } );
            BoxStroke.Color = ACCENT;
            Check.TextTransparency = 0;
            Label.TextColor3 = Color3FromRGB( 216, 216, 216 );
        elseif ( State.Hovered ) then
            BoxGrad.Color = ColorSequenceNew( {
                ColorSequenceKeypointNew( 0, SURFACE_TOP );
                ColorSequenceKeypointNew( 1, Color3FromRGB( 28, 28, 28 ) );
            } );
            BoxStroke.Color = BORDER_HOVER;
            Check.TextTransparency = 1;
            Label.TextColor3 = TEXT_HOVER;
        else
            BoxGrad.Color = ColorSequenceNew( {
                ColorSequenceKeypointNew( 0, Color3FromRGB( 32, 32, 32 ) );
                ColorSequenceKeypointNew( 1, Color3FromRGB( 24, 24, 24 ) );
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

    Container.MouseEnter : Connect( function()
        State.Hovered = true;
        Refresh();
    end );

    Container.MouseLeave : Connect( function()
        State.Hovered = false;
        Refresh();
    end );

    Refresh();

    return {
        Container = Container;
        Set = function( Value ) State.Value = Value; Refresh(); end;
        Get = function() return State.Value; end;
    };
end;

local function MakeSlider( Parent, LabelText, Default, Callback )
    local State = { Value = Default or 50, Dragging = false };

    const Container = Create( "Frame", {
        BackgroundTransparency = 1;
        Size = UDim2New( 1, 0, 0, 24 );
        Parent = Parent;
    } );

    const LabelRow = Create( "Frame", {
        BackgroundTransparency = 1;
        Size = UDim2New( 1, 0, 0, 14 );
        Parent = Container;
    } );

    Create( "TextLabel", {
        BackgroundTransparency = 1;
        Size = UDim2New( 1, 0, 1, 0 );
        Text = LabelText;
        TextColor3 = TEXT_DEFAULT;
        TextSize = 11;
        Font = FONT;
        TextXAlignment = Enum.TextXAlignment.Left;
        Parent = LabelRow;
    } );

    const ValueLabel = Create( "TextLabel", {
        BackgroundTransparency = 1;
        Size = UDim2New( 1, 0, 1, 0 );
        Text = tostring( State.Value ) .. "%";
        TextColor3 = ACCENT_BRIGHT;
        TextSize = 11;
        Font = FONT_BOLD;
        TextXAlignment = Enum.TextXAlignment.Right;
        Parent = LabelRow;
    } );

    const Track = Create( "TextButton", {
        BackgroundColor3 = Color3FromRGB( 16, 16, 16 );
        BorderSizePixel = 0;
        Position = UDim2FromOffset( 0, 16 );
        Size = UDim2New( 1, 0, 0, 5 );
        Text = "";
        AutoButtonColor = false;
        Parent = Container;
    } );
    ApplyCorner( Track, 3 );
    ApplyGradient( Track, {
        { 0, Color3FromRGB( 16, 16, 16 ) };
        { 1, Color3FromRGB( 26, 26, 26 ) };
    }, 90 );
    ApplyStroke( Track, Color3FromRGB( 46, 46, 46 ), 1, 0 );

    const Fill = Create( "Frame", {
        BackgroundColor3 = ACCENT;
        BorderSizePixel = 0;
        Position = UDim2FromOffset( 0, 0 );
        Size = UDim2New( State.Value / 100, 0, 1, 0 );
        Parent = Track;
    } );
    ApplyCorner( Fill, 3 );
    ApplyGradient( Fill, {
        { 0, ACCENT_DIM };
        { 1, ACCENT_BRIGHT };
    }, 0 );

    const Thumb = Create( "Frame", {
        BackgroundColor3 = Color3FromRGB( 224, 224, 224 );
        BorderSizePixel = 0;
        AnchorPoint = Vector2New( 0.5, 0.5 );
        Position = UDim2New( State.Value / 100, 0, 0.5, 0 );
        Size = UDim2FromOffset( 9, 9 );
        ZIndex = 2;
        Parent = Track;
    } );
    ApplyCorner( Thumb, 100 );
    ApplyGradient( Thumb, {
        { 0, Color3FromRGB( 224, 224, 224 ) };
        { 1, Color3FromRGB( 176, 176, 176 ) };
    }, 90 );
    ApplyStroke( Thumb, ACCENT, 1, 0 );

    local function Refresh()
        local Percent = State.Value / 100;
        Fill.Size = UDim2New( Percent, 0, 1, 0 );
        Thumb.Position = UDim2New( Percent, 0, 0.5, 0 );
        ValueLabel.Text = tostring( State.Value ) .. "%";
    end;

    local function FromMouse( MouseX )
        local Rel = MouseX - Track.AbsolutePosition.X;
        local Percent = math.clamp( Rel / Track.AbsoluteSize.X, 0, 1 );
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

    const Container = Create( "Frame", {
        BackgroundTransparency = 1;
        Size = UDim2New( 1, 0, 0, 20 );
        ZIndex = 3;
        Parent = Parent;
    } );

    const Trigger = Create( "TextButton", {
        BackgroundColor3 = Color3FromRGB( 35, 35, 35 );
        BorderSizePixel = 0;
        Size = UDim2New( 1, 0, 1, 0 );
        Text = "";
        AutoButtonColor = false;
        Parent = Container;
    } );
    ApplyCorner( Trigger, 3 );
    ApplyStroke( Trigger, Color3FromRGB( 58, 58, 58 ), 1, 0 );

    const TriggerGrad = ApplyGradient( Trigger, {
        { 0, Color3FromRGB( 35, 35, 35 ) };
        { 1, Color3FromRGB( 26, 26, 26 ) };
    }, 90 );

    const TriggerText = Create( "TextLabel", {
        BackgroundTransparency = 1;
        Position = UDim2FromOffset( 8, 0 );
        Size = UDim2New( 1, -20, 1, 0 );
        Text = State.Value;
        TextColor3 = TEXT_PRIMARY;
        TextSize = 11;
        Font = FONT;
        TextXAlignment = Enum.TextXAlignment.Left;
        Parent = Trigger;
    } );

    const Chevron = Create( "TextLabel", {
        BackgroundTransparency = 1;
        Position = UDim2New( 1, -14, 0, 0 );
        Size = UDim2FromOffset( 10, 20 );
        Text = "▾";
        TextColor3 = Color3FromRGB( 136, 136, 136 );
        TextSize = 10;
        Font = FONT_BOLD;
        Parent = Trigger;
    } );

    const List = Create( "Frame", {
        BackgroundColor3 = Color3FromRGB( 30, 30, 30 );
        BorderSizePixel = 0;
        Position = UDim2FromOffset( 0, 20 );
        Size = UDim2New( 1, 0, 0, 0 );
        ClipsDescendants = true;
        Visible = false;
        ZIndex = 5;
        Parent = Container;
    } );
    ApplyCorner( List, 3 );
    ApplyStroke( List, ACCENT, 1, 0 );

    Create( "UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = List;
    } );

    local Rows = { };

    for Index, Option in ipairs( Options ) do
        const Row = Create( "TextButton", {
            BackgroundTransparency = 1;
            Size = UDim2New( 1, 0, 0, 20 );
            Text = "";
            AutoButtonColor = false;
            LayoutOrder = Index;
            Parent = List;
        } );

        const RowAccent = Create( "Frame", {
            BackgroundColor3 = ACCENT;
            BorderSizePixel = 0;
            Size = UDim2FromOffset( 2, 20 );
            Visible = false;
            Parent = Row;
        } );

        const RowText = Create( "TextLabel", {
            BackgroundTransparency = 1;
            Position = UDim2FromOffset( 8, 0 );
            Size = UDim2New( 1, -8, 1, 0 );
            Text = Option;
            TextColor3 = Color3FromRGB( 184, 184, 184 );
            TextSize = 11;
            Font = FONT;
            TextXAlignment = Enum.TextXAlignment.Left;
            Parent = Row;
        } );

        Rows[ Option ] = { Row = Row; Text = RowText; Accent = RowAccent };

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

        Row.MouseEnter : Connect( function()
            State.Hovered = Option;
            Refresh();
        end );

        Row.MouseLeave : Connect( function()
            State.Hovered = nil;
            Refresh();
        end );
    end;

    local function Refresh()
        if ( State.Open ) then
            TriggerGrad.Color = ColorSequenceNew( {
                ColorSequenceKeypointNew( 0, Color3FromRGB( 40, 40, 40 ) );
                ColorSequenceKeypointNew( 1, Color3FromRGB( 30, 30, 30 ) );
            } );
        else
            TriggerGrad.Color = ColorSequenceNew( {
                ColorSequenceKeypointNew( 0, Color3FromRGB( 35, 35, 35 ) );
                ColorSequenceKeypointNew( 1, Color3FromRGB( 26, 26, 26 ) );
            } );
        end;

        Chevron.Rotation = State.Open and 180 or 0;

        for Option, Entry in pairs( Rows ) do
            if ( Option == State.Value ) then
                Entry.Text.TextColor3 = ACCENT_BRIGHT;
                Entry.Text.Font = FONT_BOLD;
                Entry.Accent.Visible = false;
            elseif ( Option == State.Hovered ) then
                Entry.Text.TextColor3 = Color3FromRGB( 221, 221, 221 );
                Entry.Text.Font = FONT;
                Entry.Accent.Visible = true;
            else
                Entry.Text.TextColor3 = Color3FromRGB( 184, 184, 184 );
                Entry.Text.Font = FONT;
                Entry.Accent.Visible = false;
            end;
        end;

        TweenService : Create( List, TweenInfoNew( 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out ), {
            Size = State.Open and UDim2New( 1, 0, 0, #Options * 20 ) or UDim2New( 1, 0, 0, 0 );
        } ) : Play();

        List.Visible = State.Open or List.Size.Y.Offset > 0;
    end;

    Trigger.MouseButton1Click : Connect( function()
        State.Open = not State.Open;
        Refresh();
    end );

    UserInputService.InputBegan : Connect( function( Input )
        if ( not State.Open ) then
            return;
        end;

        if ( Input.UserInputType ~= Enum.UserInputType.MouseButton1 ) then
            return;
        end;

        const Mouse = UserInputService : GetMouseLocation();
        const ListPos = List.AbsolutePosition;
        const ListSize = List.AbsoluteSize;

        if ( Mouse.X < ListPos.X ) or ( Mouse.X > ListPos.X + ListSize.X )
            or ( Mouse.Y < ListPos.Y ) or ( Mouse.Y > ListPos.Y + ListSize.Y + 20 ) then
            State.Open = false;
            Refresh();
        end;
    end );

    Refresh();

    return {
        Container = Container;
        Set = function( Value ) State.Value = Value; TriggerText.Text = Value; Refresh(); end;
        Get = function() return State.Value; end;
    };
end;

local function MakeKeyBind( Parent, LabelText )
    local State = { Pressed = false };

    const Button = Create( "TextButton", {
        BackgroundColor3 = Color3FromRGB( 44, 44, 44 );
        BorderSizePixel = 0;
        Size = UDim2FromOffset( 24, 16 );
        Text = LabelText;
        TextColor3 = Color3FromRGB( 192, 192, 192 );
        TextSize = 10;
        Font = FONT_BOLD;
        AutoButtonColor = false;
        Parent = Parent;
    } );
    ApplyCorner( Button, 2 );
    ApplyGradient( Button, {
        { 0, Color3FromRGB( 44, 44, 44 ) };
        { 1, Color3FromRGB( 32, 32, 32 ) };
    }, 90 );
    const StrokeRef = ApplyStroke( Button, Color3FromRGB( 74, 74, 74 ), 1, 0 );

    local function Refresh()
        if ( State.Pressed ) then
            Button.TextColor3 = Color3New( 1, 1, 1 );
            StrokeRef.Color = ACCENT;
            Button.BackgroundColor3 = Color3FromRGB( 36, 36, 36 );
        else
            Button.TextColor3 = Color3FromRGB( 192, 192, 192 );
            StrokeRef.Color = Color3FromRGB( 74, 74, 74 );
            Button.BackgroundColor3 = Color3FromRGB( 44, 44, 44 );
        end;
    end;

    Button.MouseButton1Down : Connect( function() State.Pressed = true; Refresh(); end );
    Button.MouseButton1Up   : Connect( function() State.Pressed = false; Refresh(); end );
    Button.MouseLeave       : Connect( function() State.Pressed = false; Refresh(); end );

    Refresh();

    return Button;
end;

local function MakeColorSwatch( Parent, ColorA, ColorB, BorderColor )
    const Swatch = Create( "Frame", {
        BackgroundColor3 = ColorA;
        BorderSizePixel = 0;
        Size = UDim2FromOffset( 20, 13 );
        Parent = Parent;
    } );
    ApplyCorner( Swatch, 2 );
    ApplyGradient( Swatch, {
        { 0, ColorA };
        { 1, ColorB };
    }, 90 );
    ApplyStroke( Swatch, BorderColor, 1, 0 );

    return Swatch;
end;

local function MakeDivider( Parent )
    const Divider = Create( "Frame", {
        BackgroundColor3 = Color3FromRGB( 44, 44, 44 );
        BorderSizePixel = 0;
        Size = UDim2New( 1, 0, 0, 1 );
        Parent = Parent;
    } );
    ApplyGradient( Divider, {
        { 0, Color3FromRGB( 22, 22, 22 ) };
        { 0.2, Color3FromRGB( 44, 44, 44 ) };
        { 0.5, Color3FromRGB( 56, 56, 56 ) };
        { 0.8, Color3FromRGB( 44, 44, 44 ) };
        { 1, Color3FromRGB( 22, 22, 22 ) };
    }, 0 );

    return Divider;
end;

local function MakeSectionLabel( Parent, Text )
    return Create( "TextLabel", {
        BackgroundTransparency = 1;
        Size = UDim2New( 1, 0, 0, 12 );
        Text = string.upper( Text );
        TextColor3 = Color3FromRGB( 120, 120, 120 );
        TextSize = 10;
        Font = FONT;
        TextXAlignment = Enum.TextXAlignment.Left;
        Parent = Parent;
    } );
end;

local function MakePanelHeading( Parent, Text )
    const Container = Create( "Frame", {
        BackgroundTransparency = 1;
        Size = UDim2New( 1, 0, 0, 16 );
        Parent = Parent;
    } );

    const AccentBar = Create( "Frame", {
        BackgroundColor3 = ACCENT_BRIGHT;
        BorderSizePixel = 0;
        Position = UDim2FromOffset( 0, 2 );
        Size = UDim2FromOffset( 3, 11 );
        Parent = Container;
    } );
    ApplyCorner( AccentBar, 1 );
    ApplyGradient( AccentBar, {
        { 0, ACCENT_BRIGHT };
        { 1, ACCENT_DIM };
    }, 90 );

    Create( "TextLabel", {
        BackgroundTransparency = 1;
        Position = UDim2FromOffset( 8, 0 );
        Size = UDim2New( 1, -8, 1, 0 );
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

    const Tab = Create( "TextButton", {
        BackgroundColor3 = Color3FromRGB( 28, 28, 28 );
        BorderSizePixel = 0;
        Size = UDim2FromOffset( 60, Small and 22 or 24 );
        Text = "";
        AutoButtonColor = false;
        LayoutOrder = LayoutOrder or 0;
        Parent = Parent;
    } );

    const Label = Create( "TextLabel", {
        BackgroundTransparency = 1;
        Size = UDim2New( 1, 0, 1, 0 );
        Text = Text;
        TextColor3 = TEXT_MUTED;
        TextSize = Small and 10 or 11;
        Font = FONT;
        Parent = Tab;
    } );

    const TopBorder = Create( "Frame", {
        BackgroundColor3 = BORDER_FAINT;
        BorderSizePixel = 0;
        Size = UDim2New( 1, 0, 0, 1 );
        Parent = Tab;
    } );

    local function Refresh()
        if ( State.Active ) then
            Tab.BackgroundColor3 = Color3FromRGB( 32, 32, 32 );
            Label.TextColor3 = Color3FromRGB( 224, 224, 224 );
            Label.Font = FONT_BOLD;
            TopBorder.BackgroundColor3 = ACCENT;
        elseif ( State.Hovered ) then
            Tab.BackgroundColor3 = Color3FromRGB( 34, 34, 34 );
            Label.TextColor3 = TEXT_HOVER;
            Label.Font = FONT;
            TopBorder.BackgroundColor3 = Color3FromRGB( 64, 64, 64 );
        else
            Tab.BackgroundColor3 = Color3FromRGB( 28, 28, 28 );
            Label.TextColor3 = TEXT_MUTED;
            Label.Font = FONT;
            TopBorder.BackgroundColor3 = BORDER_FAINT;
        end;

        local Padding = Small and 18 or 24;
        Tab.Size = UDim2FromOffset( Label.TextBounds.X + Padding, Small and 22 or 24 );
    end;

    Tab.MouseButton1Click : Connect( function()
        if ( OnClick ) then
            OnClick();
        end;
    end );

    Tab.MouseEnter : Connect( function() State.Hovered = true; Refresh(); end );
    Tab.MouseLeave : Connect( function() State.Hovered = false; Refresh(); end );

    Refresh();

    return {
        Tab = Tab;
        SetActive = function( Value ) State.Active = Value; Refresh(); end;
    };
end;

-- ── Window ────────────────────────────────────────────────────────────────────

const PANEL_WIDTH = 230;
const RIGHT_WIDTH = 190;

local Interface = { };
Interface.__index = Interface;

function Interface.new( Title )
    Title = Title or "juanita****.club";

    const ScreenGui = Create( "ScreenGui", {
        Name = "juanita_club";
        ResetOnSpawn = false;
        IgnoreGuiInset = true;
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
        Parent = CoreGui;
    } );

    const Window = Create( "Frame", {
        BackgroundColor3 = BG_WINDOW;
        BorderSizePixel = 0;
        AnchorPoint = Vector2New( 0.5, 0.5 );
        Position = UDim2New( 0.5, 0, 0.5, 0 );
        Size = UDim2FromOffset( 420, 380 );
        ClipsDescendants = true;
        Parent = ScreenGui;
    } );
    ApplyCorner( Window, 4 );
    ApplyStroke( Window, BORDER_EDGE, 1, 0 );

    const GlowRing = Create( "Frame", {
        BackgroundTransparency = 1;
        Size = Window.Size;
        Position = Window.Position;
        ZIndex = 0;
        Parent = ScreenGui;
    } );
    ApplyStroke( GlowRing, ACCENT, 1, 0.93 );
    ApplyCorner( GlowRing, 4 );

    Create( "UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder;
        Padding = UDimFromOffset( 0 );
        Parent = Window;
    } );

    -- Title bar
    const TitleBar = Create( "Frame", {
        BackgroundColor3 = Color3FromRGB( 34, 34, 34 );
        BorderSizePixel = 0;
        Size = UDim2New( 1, 0, 0, 26 );
        LayoutOrder = 1;
        Parent = Window;
    } );
    ApplyGradient( TitleBar, {
        { 0, Color3FromRGB( 42, 42, 42 ) };
        { 0.5, Color3FromRGB( 31, 31, 31 ) };
        { 1, Color3FromRGB( 26, 26, 26 ) };
    }, 90 );

    Create( "Frame", {
        BackgroundColor3 = Color3FromRGB( 10, 10, 10 );
        BorderSizePixel = 0;
        Size = UDim2New( 1, 0, 0, 1 );
        Position = UDim2New( 0, 0, 1, -1 );
        Parent = TitleBar;
    } );

    const BrandMark = Create( "Frame", {
        BackgroundColor3 = ACCENT_BRIGHT;
        BorderSizePixel = 0;
        Position = UDim2FromOffset( 10, 7 );
        Size = UDim2FromOffset( 10, 12 );
        Parent = TitleBar;
    } );
    ApplyCorner( BrandMark, 2 );
    ApplyGradient( BrandMark, {
        { 0, ACCENT_BRIGHT };
        { 1, ACCENT_DIM };
    }, 90 );

    Create( "TextLabel", {
        BackgroundTransparency = 1;
        Position = UDim2FromOffset( 24, 0 );
        Size = UDim2New( 1, -90, 1, 0 );
        Text = Title;
        TextColor3 = TEXT_PRIMARY;
        TextSize = 11;
        Font = FONT_MEDIUM;
        TextXAlignment = Enum.TextXAlignment.Left;
        Parent = TitleBar;
    } );

    const TitleButtons = Create( "Frame", {
        BackgroundTransparency = 1;
        Position = UDim2New( 1, -42, 0, 6 );
        Size = UDim2FromOffset( 38, 14 );
        Parent = TitleBar;
    } );

    const MinBtn = Create( "TextButton", {
        BackgroundColor3 = Color3FromRGB( 46, 46, 46 );
        BorderSizePixel = 0;
        Position = UDim2FromOffset( 0, 0 );
        Size = UDim2FromOffset( 18, 14 );
        Text = "−";
        TextColor3 = Color3FromRGB( 144, 144, 144 );
        TextSize = 11;
        Font = FONT;
        AutoButtonColor = false;
        Parent = TitleButtons;
    } );
    ApplyCorner( MinBtn, 2 );
    ApplyStroke( MinBtn, Color3FromRGB( 72, 72, 72 ), 1, 0 );

    const CloseBtn = Create( "TextButton", {
        BackgroundColor3 = Color3FromRGB( 146, 32, 32 );
        BorderSizePixel = 0;
        Position = UDim2FromOffset( 21, 0 );
        Size = UDim2FromOffset( 18, 14 );
        Text = "✕";
        TextColor3 = Color3FromRGB( 238, 238, 238 );
        TextSize = 10;
        Font = FONT;
        AutoButtonColor = false;
        Parent = TitleButtons;
    } );
    ApplyCorner( CloseBtn, 2 );
    ApplyStroke( CloseBtn, Color3FromRGB( 106, 16, 16 ), 1, 0 );

    -- Main tab strip
    const TabStrip = Create( "Frame", {
        BackgroundColor3 = Color3FromRGB( 22, 22, 22 );
        BorderSizePixel = 0;
        Size = UDim2New( 1, 0, 0, 28 );
        LayoutOrder = 2;
        Parent = Window;
    } );
    ApplyGradient( TabStrip, {
        { 0, Color3FromRGB( 22, 22, 22 ) };
        { 1, Color3FromRGB( 18, 18, 18 ) };
    }, 90 );

    Create( "Frame", {
        BackgroundColor3 = Color3FromRGB( 46, 46, 46 );
        BorderSizePixel = 0;
        Size = UDim2New( 1, 0, 0, 1 );
        Position = UDim2New( 0, 0, 1, -1 );
        Parent = TabStrip;
    } );

    const TabHolder = Create( "Frame", {
        BackgroundTransparency = 1;
        Position = UDim2FromOffset( 6, 4 );
        Size = UDim2New( 1, -12, 1, -4 );
        Parent = TabStrip;
    } );

    Create( "UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Padding = UDimFromOffset( 2 );
        VerticalAlignment = Enum.VerticalAlignment.Bottom;
        Parent = TabHolder;
    } );

    -- Body
    const Body = Create( "Frame", {
        BackgroundColor3 = BG_WINDOW;
        BorderSizePixel = 0;
        Size = UDim2New( 1, 0, 0, 300 );
        LayoutOrder = 3;
        Parent = Window;
    } );

    const LeftPanel = Create( "Frame", {
        BackgroundColor3 = BG_WINDOW;
        BorderSizePixel = 0;
        Size = UDim2FromOffset( PANEL_WIDTH, 300 );
        Parent = Body;
    } );

    const LeftInner = Create( "Frame", {
        BackgroundTransparency = 1;
        Position = UDim2FromOffset( 12, 10 );
        Size = UDim2FromOffset( PANEL_WIDTH - 24, 0 );
        AutomaticSize = Enum.AutomaticSize.Y;
        Parent = LeftPanel;
    } );

    Create( "UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder;
        Padding = UDimFromOffset( 0 );
        Parent = LeftInner;
    } );

    const PanelDivider = Create( "Frame", {
        BackgroundColor3 = Color3FromRGB( 32, 32, 32 );
        BorderSizePixel = 0;
        Position = UDim2FromOffset( PANEL_WIDTH, 0 );
        Size = UDim2FromOffset( 1, 300 );
        Parent = Body;
    } );

    const RightPanel = Create( "Frame", {
        BackgroundColor3 = BG_WINDOW;
        BorderSizePixel = 0;
        Position = UDim2FromOffset( PANEL_WIDTH + 1, 0 );
        Size = UDim2FromOffset( RIGHT_WIDTH, 300 );
        Parent = Body;
    } );

    const RightInner = Create( "Frame", {
        BackgroundTransparency = 1;
        Position = UDim2FromOffset( 10, 8 );
        Size = UDim2FromOffset( RIGHT_WIDTH - 20, 0 );
        AutomaticSize = Enum.AutomaticSize.Y;
        Parent = RightPanel;
    } );

    -- Footer
    const Footer = Create( "Frame", {
        BackgroundColor3 = BG_FOOTER;
        BorderSizePixel = 0;
        Size = UDim2New( 1, 0, 0, 20 );
        LayoutOrder = 4;
        Parent = Window;
    } );
    ApplyGradient( Footer, {
        { 0, Color3FromRGB( 18, 18, 18 ) };
        { 1, Color3FromRGB( 14, 14, 14 ) };
    }, 90 );

    Create( "Frame", {
        BackgroundColor3 = Color3FromRGB( 30, 30, 30 );
        BorderSizePixel = 0;
        Size = UDim2New( 1, 0, 0, 1 );
        Parent = Footer;
    } );

    Create( "TextLabel", {
        BackgroundTransparency = 1;
        Position = UDim2FromOffset( 10, 0 );
        Size = UDim2New( 1, -20, 1, 0 );
        Text = "build 2.4.1";
        TextColor3 = TEXT_FAINT;
        TextSize = 9;
        Font = FONT;
        TextXAlignment = Enum.TextXAlignment.Left;
        Parent = Footer;
    } );

    const StatusDot = Create( "Frame", {
        BackgroundColor3 = Color3FromRGB( 46, 204, 85 );
        BorderSizePixel = 0;
        AnchorPoint = Vector2New( 1, 0.5 );
        Position = UDim2New( 1, -50, 0.5, 0 );
        Size = UDim2FromOffset( 5, 5 );
        Parent = Footer;
    } );
    ApplyCorner( StatusDot, 100 );

    Create( "TextLabel", {
        BackgroundTransparency = 1;
        AnchorPoint = Vector2New( 1, 0.5 );
        Position = UDim2New( 1, -10, 0.5, 0 );
        Size = UDim2FromOffset( 36, 12 );
        Text = "CONNECTED";
        TextColor3 = TEXT_FAINT;
        TextSize = 9;
        Font = FONT;
        TextXAlignment = Enum.TextXAlignment.Right;
        Parent = Footer;
    } );

    -- Drag
    local Drag = { Active = false; StartMouse = Vector2New( 0, 0 ); StartPos = UDim2New( 0, 0, 0, 0 ) };

    TitleBar.InputBegan : Connect( function( Input )
        if ( Input.UserInputType ~= Enum.UserInputType.MouseButton1 ) then
            return;
        end;

        Drag.Active = true;
        Drag.StartMouse = Vector2New( Input.Position.X, Input.Position.Y );
        Drag.StartPos = Window.Position;
    end );

    UserInputService.InputChanged : Connect( function( Input )
        if ( not Drag.Active ) then return; end;
        if ( Input.UserInputType ~= Enum.UserInputType.MouseMovement ) then return; end;

        const DeltaX = Input.Position.X - Drag.StartMouse.X;
        const DeltaY = Input.Position.Y - Drag.StartMouse.Y;

        Window.Position = UDim2New(
            Drag.StartPos.X.Scale, Drag.StartPos.X.Offset + DeltaX,
            Drag.StartPos.Y.Scale, Drag.StartPos.Y.Offset + DeltaY
        );

        GlowRing.Position = Window.Position;
        GlowRing.Size = Window.Size;
    end );

    UserInputService.InputEnded : Connect( function( Input )
        if ( Input.UserInputType == Enum.UserInputType.MouseButton1 ) then
            Drag.Active = false;
        end;
    end );

    CloseBtn.MouseButton1Click : Connect( function()
        ScreenGui : Destroy();
    end );

    MinBtn.MouseButton1Click : Connect( function()
        Window.Visible = not Window.Visible;
    end );

    -- Left area holds a single active page at a time
    const LeftPages = { };
    const LeftTabs = { };
    const RightPages = { };
    const RightTabs = { };

    local API = setmetatable( {
        ScreenGui = ScreenGui;
        Window = Window;
        TabHolder = TabHolder;
        RightInner = RightInner;
        LeftInner = LeftInner;
        LeftPages = LeftPages;
        RightPages = RightPages;
        MainTabs = LeftTabs;
        RightTabs = RightTabs;
        ActiveLeftTab = nil;
        ActiveRightTab = nil;
    }, Interface );

    function API : AddLeftTab( Name )
        if ( LeftPages[ Name ] ) then
            return LeftPages[ Name ];
        end;

        const Page = Create( "Frame", {
            BackgroundTransparency = 1;
            Size = UDim2FromOffset( PANEL_WIDTH - 24, 0 );
            AutomaticSize = Enum.AutomaticSize.Y;
            LayoutOrder = 1;
            Visible = false;
            Parent = LeftInner;
        } );

        Create( "UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder;
            Padding = UDimFromOffset( 5 );
            Parent = Page;
        } );

        const TabAPI = MakeTab( TabHolder, Name, false, #LeftPages + 1, function()
            API : SelectLeftTab( Name );
        end );

        LeftPages[ Name ] = Page;
        LeftTabs[ Name ] = TabAPI;

        return Page;
    end;

    function API : SelectLeftTab( Name )
        for TabName, Page in pairs( LeftPages ) do
            Page.Visible = ( TabName == Name );
        end;

        for TabName, Tab in pairs( LeftTabs ) do
            Tab : SetActive( TabName == Name );
        end;

        API.ActiveLeftTab = Name;

        if ( API.Heading ) then
            API.Heading : Destroy();
        end;

        const Holder = Create( "Frame", {
            BackgroundTransparency = 1;
            Size = UDim2New( 1, 0, 0, 22 );
            LayoutOrder = 0;
            Parent = LeftInner;
        } );
        API.Heading = MakePanelHeading( Holder, Name );
        API.Heading.Size = UDim2New( 1, 0, 1, 0 );
    end;

    function API : AddRightTab( Name )
        if ( RightPages[ Name ] ) then
            return RightPages[ Name ];
        end;

        const Page = Create( "Frame", {
            BackgroundTransparency = 1;
            Size = UDim2FromOffset( RIGHT_WIDTH - 20, 0 );
            AutomaticSize = Enum.AutomaticSize.Y;
            Visible = false;
            Parent = RightInner;
        } );

        Create( "UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder;
            Padding = UDimFromOffset( 5 );
            Parent = Page;
        } );

        RightPages[ Name ] = Page;
        RightTabs[ Name ] = Page;

        return Page;
    end;

    function API : SelectRightTab( Name )
        for TabName, Page in pairs( RightPages ) do
            Page.Visible = ( TabName == Name );
        end;
        API.ActiveRightTab = Name;
    end;

    -- Right sub-tab strip (drawn on top of the right panel)
    const RightStrip = Create( "Frame", {
        BackgroundTransparency = 1;
        Position = UDim2FromOffset( 0, 0 );
        Size = UDim2FromOffset( RIGHT_WIDTH - 20, 22 );
        Parent = RightInner;
    } );

    Create( "Frame", {
        BackgroundColor3 = Color3FromRGB( 46, 46, 46 );
        BorderSizePixel = 0;
        Size = UDim2New( 1, 0, 0, 1 );
        Position = UDim2New( 0, 0, 1, -1 );
        Parent = RightStrip;
    } );

    Create( "UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Padding = UDimFromOffset( 1 );
        VerticalAlignment = Enum.VerticalAlignment.Bottom;
        Parent = RightStrip;
    } );

    API.RightStrip = RightStrip;

    -- Resize window to fit content
    task.defer( function()
        task.wait();

        local MaxHeight = 260;

        for _, Page in pairs( LeftPages ) do
            MaxHeight = math.max( MaxHeight, Page.AbsoluteSize.Y + 40 );
        end;

        for _, Page in pairs( RightPages ) do
            MaxHeight = math.max( MaxHeight, Page.AbsoluteSize.Y + 60 );
        end;

        Body.Size = UDim2New( 1, 0, 0, MaxHeight );
        LeftPanel.Size = UDim2FromOffset( PANEL_WIDTH, MaxHeight );
        PanelDivider.Size = UDim2FromOffset( 1, MaxHeight );
        RightPanel.Size = UDim2FromOffset( RIGHT_WIDTH, MaxHeight );

        Window.Size = UDim2FromOffset( 420, 26 + 28 + MaxHeight + 20 );
        GlowRing.Size = Window.Size;
        GlowRing.Position = Window.Position;
    end );

    return API;
end;

-- Public helper: build a checkbox inside a Page
function Interface : Checkbox( Label, Default, Callback )
    return MakeCheckbox( self, Label, Default, Callback );
end;

function Interface : Slider( Label, Default, Callback )
    return MakeSlider( self, Label, Default, Callback );
end;

function Interface : Dropdown( Options, Default, Callback )
    return MakeDropdown( self, Options, Default, Callback );
end;

function Interface : Divider()
    return MakeDivider( self );
end;

function Interface : Label( Text )
    return MakeSectionLabel( self, Text );
end;



-- ── Example usage ─────────────────────────────────────────────────────────────

--[[
    Copy the code above into a LocalScript / executor and then run the block
    below. It builds a fully functional window with two left tabs and one
    right sub-tab, wired up to print their values.

    local UI = Interface.new( "my menu" )

    -- ── Left tab: Combat ───────────────────────────────────────────────
    local Combat = UI : AddLeftTab( "Combat" )

    Combat : Checkbox( "Enabled", true, function( Value )
        print( "[Combat] Enabled =", Value )
    end )

    Combat : Checkbox( "Silent Aim", false, function( Value )
        print( "[Combat] Silent Aim =", Value )
    end )

    Combat : Slider( "FOV", 50, function( Value )
        print( "[Combat] FOV =", Value )
    end )

    Combat : Divider()
    Combat : Label( "Hitbox" )

    Combat : Dropdown( { "Head", "Neck", "Body", "Legs" }, "Head", function( Choice )
        print( "[Combat] Hitbox =", Choice )
    end )

    -- ── Left tab: Misc ─────────────────────────────────────────────────
    local Misc = UI : AddLeftTab( "Misc" )

    for _, Name in ipairs( { "Bunny Hop", "Auto Strafe", "Radar", "No Flash" } ) do
        Misc : Checkbox( Name, false, function( Value )
            print( "[Misc]", Name, "=", Value )
        end )
    end

    -- ── Right sub-tab: Visuals ────────────────────────────────────────
    local Visuals = UI : AddRightTab( "Visuals" )

    Visuals : Checkbox( "Player ESP", true, function( Value )
        print( "[ESP] Player =", Value )
    end )

    Visuals : Dropdown( { "Box", "Corner", "3D", "None" }, "Box", function( Choice )
        print( "[ESP] Style =", Choice )
    end )

    -- Right sub-tab strip buttons (small style)
    MakeTab( UI.RightStrip, "Visuals", true, 1, function()
        UI : SelectRightTab( "Visuals" )
    end ) : SetActive( true )

    -- ── Show the initial tabs ──────────────────────────────────────────
    UI : SelectLeftTab( "Combat" )
    UI : SelectRightTab( "Visuals" )

    print( "Window ready." )
]]

return Interface;

