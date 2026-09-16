--[[ juanita****.club — Port of App.tsx / index.css ]]

local Game = game;
local UIS  = Game : GetService( "UserInputService" );
local Tw   = Game : GetService( "TweenService" );
local CG   = Game : GetService( "CoreGui" );

-- Palette
local ACCENT        = Color3.fromRGB( 212, 90, 16 );
local ACCENT_BRIGHT = Color3.fromRGB( 232, 112, 26 );
local ACCENT_DIM    = Color3.fromRGB( 154, 60, 8 );

local TX_DEFAULT  = Color3.fromRGB( 160, 160, 160 );
local TX_HOVER    = Color3.fromRGB( 184, 184, 184 );
local TX_ACTIVE   = Color3.fromRGB( 216, 216, 216 );
local TX_PRIMARY  = Color3.fromRGB( 200, 200, 200 );
local TX_MUTED    = Color3.fromRGB( 112, 112, 112 );
local TX_FAINT    = Color3.fromRGB( 62, 62, 62 );

local BG_WIN    = Color3.fromRGB( 22, 22, 22 );
local BG_FOOT   = Color3.fromRGB( 14, 14, 14 );

local B_SOFT   = Color3.fromRGB( 54, 54, 54 );
local B_HOVER  = Color3.fromRGB( 74, 74, 74 );
local B_FAINT  = Color3.fromRGB( 40, 40, 40 );
local B_EDGE   = Color3.fromRGB( 13, 13, 13 );

local FT   = Enum.Font.Gotham;
local FTM  = Enum.Font.GothamMedium;
local FTB  = Enum.Font.GothamBold;

local PANEL_W = 200;
local RIGHT_W = 180;

local function O( N ) return UDim.new( 0, N ); end;
local function O2( X, Y ) return UDim2.new( 0, X or 0, 0, Y or 0 ); end;

local function C( Class, Props )
    local I = Instance.new( Class );
    for K, V in pairs( Props ) do I[ K ] = V; end;
    return I;
end;

local function GR( Obj, Stops, Rot )
    local Pts = { };
    for i, S in ipairs( Stops ) do
        Pts[ i ] = ColorSequenceKeypoint.new( S[ 1 ], S[ 2 ] );
    end;
    return C( "UIGradient", {
        Color = ColorSequence.new( Pts );
        Rotation = Rot or 90;
        Parent = Obj;
    } );
end;

local function CR( Obj, R )
    return C( "UICorner", { CornerRadius = UDim.new( 0, R ); Parent = Obj; } );
end;

local function ST( Obj, Clr, T )
    return C( "UIStroke", {
        Color = Clr;
        Thickness = 1;
        Transparency = T or 0;
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
        Parent = Obj;
    } );
end;

-- ── Atoms ───────────────────────────────────────────────────────────────────

local function Checkbox( Parent, Text, Def, CB )
    local S = { V = Def or false, H = false };

    local Row = C( "Frame", {
        BackgroundTransparency = 1;
        Size = UDim2.new( 1, 0, 0, 14 );
        Parent = Parent;
    } );

    local Box = C( "Frame", {
        Size = O2( 11, 11 );
        Position = O2( 0, 1 );
        BorderSizePixel = 0;
        Parent = Row;
    } );
    CR( Box, 2 );

    local BoxG = GR( Box, {
        { 0, Color3.fromRGB( 32, 32, 32 ) };
        { 1, Color3.fromRGB( 24, 24, 24 ) };
    }, 90 );
    local BoxS = ST( Box, B_SOFT );

    local Tick = C( "TextLabel", {
        BackgroundTransparency = 1;
        Size = UDim2.new( 1, 0, 1, 0 );
        Text = "✓";
        TextColor3 = Color3.new( 1, 1, 1 );
        TextSize = 9;
        Font = FTB;
        TextTransparency = 1;
        Parent = Box;
    } );

    local Label = C( "TextLabel", {
        BackgroundTransparency = 1;
        Position = O2( 17, 0 );
        Size = UDim2.new( 1, -17, 1, 0 );
        Text = Text;
        TextColor3 = TX_DEFAULT;
        TextSize = 10;
        Font = FT;
        TextXAlignment = Enum.TextXAlignment.Left;
        Parent = Row;
    } );

    local function Refresh()
        if S.V then
            BoxG.Color = ColorSequence.new( {
                ColorSequenceKeypoint.new( 0, ACCENT );
                ColorSequenceKeypoint.new( 1, ACCENT_DIM );
            } );
            BoxS.Color = ACCENT;
            Tick.TextTransparency = 0;
            Label.TextColor3 = TX_ACTIVE;
        elseif S.H then
            BoxG.Color = ColorSequence.new( {
                ColorSequenceKeypoint.new( 0, Color3.fromRGB( 37, 37, 37 ) );
                ColorSequenceKeypoint.new( 1, Color3.fromRGB( 28, 28, 28 ) );
            } );
            BoxS.Color = B_HOVER;
            Tick.TextTransparency = 1;
            Label.TextColor3 = TX_HOVER;
        else
            BoxG.Color = ColorSequence.new( {
                ColorSequenceKeypoint.new( 0, Color3.fromRGB( 32, 32, 32 ) );
                ColorSequenceKeypoint.new( 1, Color3.fromRGB( 24, 24, 24 ) );
            } );
            BoxS.Color = B_SOFT;
            Tick.TextTransparency = 1;
            Label.TextColor3 = TX_DEFAULT;
        end;
    end;

    Row.InputBegan : Connect( function( Inp )
        if Inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return; end;
        S.V = not S.V; Refresh();
        if CB then CB( S.V ); end;
    end );
    Row.MouseEnter : Connect( function() S.H = true; Refresh(); end );
    Row.MouseLeave : Connect( function() S.H = false; Refresh(); end );

    Refresh();
    return { Container = Row; Set = function( V ) S.V = V; Refresh(); end; Get = function() return S.V; end; };
end;

local function Slider( Parent, Text, Def, CB )
    local S = { V = Def or 50, D = false };

    local Row = C( "Frame", {
        BackgroundTransparency = 1;
        Size = UDim2.new( 1, 0, 0, 20 );
        Parent = Parent;
    } );

    local LR = C( "Frame", {
        BackgroundTransparency = 1;
        Size = UDim2.new( 1, 0, 0, 11 );
        Parent = Row;
    } );

    C( "TextLabel", {
        BackgroundTransparency = 1;
        Size = UDim2.new( 1, 0, 1, 0 );
        Text = Text;
        TextColor3 = TX_DEFAULT;
        TextSize = 10;
        Font = FT;
        TextXAlignment = Enum.TextXAlignment.Left;
        Parent = LR;
    } );

    local VL = C( "TextLabel", {
        BackgroundTransparency = 1;
        Size = UDim2.new( 1, 0, 1, 0 );
        Text = tostring( S.V ) .. "%";
        TextColor3 = ACCENT_BRIGHT;
        TextSize = 10;
        Font = FTB;
        TextXAlignment = Enum.TextXAlignment.Right;
        Parent = LR;
    } );

    local Track = C( "TextButton", {
        BackgroundColor3 = Color3.fromRGB( 16, 16, 16 );
        BorderSizePixel = 0;
        Position = O2( 0, 14 );
        Size = UDim2.new( 1, 0, 0, 3 );
        Text = "";
        AutoButtonColor = false;
        Parent = Row;
    } );
    CR( Track, 2 );
    GR( Track, { { 0, Color3.fromRGB( 16, 16, 16 ) }; { 1, Color3.fromRGB( 26, 26, 26 ) }; }, 90 );
    ST( Track, Color3.fromRGB( 46, 46, 46 ) );

    local Fill = C( "Frame", {
        BackgroundColor3 = ACCENT;
        BorderSizePixel = 0;
        Size = UDim2.new( S.V / 100, 0, 1, 0 );
        Parent = Track;
    } );
    CR( Fill, 2 );
    GR( Fill, { { 0, ACCENT_DIM }; { 1, ACCENT_BRIGHT }; }, 0 );

    local Thumb = C( "Frame", {
        BackgroundColor3 = Color3.fromRGB( 224, 224, 224 );
        BorderSizePixel = 0;
        AnchorPoint = Vector2.new( 0.5, 0.5 );
        Position = UDim2.new( S.V / 100, 0, 0.5, 0 );
        Size = O2( 7, 7 );
        ZIndex = 2;
        Parent = Track;
    } );
    CR( Thumb, 100 );
    GR( Thumb, { { 0, Color3.fromRGB( 224, 224, 224 ) }; { 1, Color3.fromRGB( 176, 176, 176 ) }; }, 90 );
    ST( Thumb, ACCENT );

    local function Refresh()
        local P = S.V / 100;
        Fill.Size = UDim2.new( P, 0, 1, 0 );
        Thumb.Position = UDim2.new( P, 0, 0.5, 0 );
        VL.Text = tostring( S.V ) .. "%";
    end;

    local function FromMouse( X )
        local P = math.clamp( ( X - Track.AbsolutePosition.X ) / Track.AbsoluteSize.X, 0, 1 );
        S.V = math.floor( P * 100 );
        Refresh();
        if CB then CB( S.V ); end;
    end;

    Track.InputBegan : Connect( function( Inp )
        if Inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return; end;
        S.D = true; FromMouse( Inp.Position.X );
    end );
    UIS.InputChanged : Connect( function( Inp )
        if S.D and Inp.UserInputType == Enum.UserInputType.MouseMovement then FromMouse( Inp.Position.X ); end;
    end );
    UIS.InputEnded : Connect( function( Inp )
        if Inp.UserInputType == Enum.UserInputType.MouseButton1 then S.D = false; end;
    end );

    Refresh();
    return { Container = Row; Set = function( V ) S.V = V; Refresh(); end; Get = function() return S.V; end; };
end;

local function Dropdown( Parent, Options, Def, CB )
    local S = { V = Def or Options[ 1 ] or "", Op = false, H = nil };

    local Box = C( "Frame", {
        BackgroundTransparency = 1;
        Size = UDim2.new( 1, 0, 0, 16 );
        ZIndex = 3;
        Parent = Parent;
    } );

    local Trig = C( "TextButton", {
        BorderSizePixel = 0;
        Size = UDim2.new( 1, 0, 1, 0 );
        Text = "";
        AutoButtonColor = false;
        Parent = Box;
    } );
    CR( Trig, 3 );
    ST( Trig, Color3.fromRGB( 58, 58, 58 ) );
    local TG = GR( Trig, { { 0, Color3.fromRGB( 35, 35, 35 ) }; { 1, Color3.fromRGB( 26, 26, 26 ) }; }, 90 );

    local TT = C( "TextLabel", {
        BackgroundTransparency = 1;
        Position = O2( 7, 0 );
        Size = UDim2.new( 1, -18, 1, 0 );
        Text = S.V;
        TextColor3 = TX_PRIMARY;
        TextSize = 10;
        Font = FT;
        TextXAlignment = Enum.TextXAlignment.Left;
        Parent = Trig;
    } );

    local Chev = C( "TextLabel", {
        BackgroundTransparency = 1;
        Position = UDim2.new( 1, -13, 0, 0 );
        Size = O2( 9, 16 );
        Text = "v";
        TextColor3 = Color3.fromRGB( 136, 136, 136 );
        TextSize = 10;
        Font = FTB;
        Parent = Trig;
    } );

    local List = C( "Frame", {
        BackgroundColor3 = Color3.fromRGB( 30, 30, 30 );
        BorderSizePixel = 0;
        Position = O2( 0, 16 );
        Size = UDim2.new( 1, 0, 0, 0 );
        ClipsDescendants = true;
        Visible = false;
        ZIndex = 5;
        Parent = Box;
    } );
    CR( List, 3 );
    ST( List, ACCENT );
    C( "UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder; Parent = List; } );

    local Rows = { };

    for i, Opt in ipairs( Options ) do
        local Row = C( "TextButton", {
            BackgroundTransparency = 1;
            Size = UDim2.new( 1, 0, 0, 16 );
            Text = "";
            AutoButtonColor = false;
            LayoutOrder = i;
            Parent = List;
        } );

        local Acc = C( "Frame", {
            BackgroundColor3 = ACCENT;
            BorderSizePixel = 0;
            Size = O2( 2, 16 );
            Visible = false;
            Parent = Row;
        } );

        local RowT = C( "TextLabel", {
            BackgroundTransparency = 1;
            Position = O2( 7, 0 );
            Size = UDim2.new( 1, -7, 1, 0 );
            Text = Opt;
            TextColor3 = Color3.fromRGB( 184, 184, 184 );
            TextSize = 10;
            Font = FT;
            TextXAlignment = Enum.TextXAlignment.Left;
            Parent = Row;
        } );

        Rows[ Opt ] = { Text = RowT, Acc = Acc };

        Row.InputBegan : Connect( function( Inp )
            if Inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return; end;
            S.V = Opt; TT.Text = Opt;
            if CB then CB( Opt ); end;
            S.Op = false; Refresh();
        end );
        Row.MouseEnter : Connect( function() S.H = Opt; Refresh(); end );
        Row.MouseLeave : Connect( function() S.H = nil; Refresh(); end );
    end;

    local function Refresh()
        if S.Op then
            TG.Color = ColorSequence.new( {
                ColorSequenceKeypoint.new( 0, Color3.fromRGB( 40, 40, 40 ) );
                ColorSequenceKeypoint.new( 1, Color3.fromRGB( 30, 30, 30 ) );
            } );
            Chev.Rotation = 180;
        else
            TG.Color = ColorSequence.new( {
                ColorSequenceKeypoint.new( 0, Color3.fromRGB( 35, 35, 35 ) );
                ColorSequenceKeypoint.new( 1, Color3.fromRGB( 26, 26, 26 ) );
            } );
            Chev.Rotation = 0;
        end;

        for Opt, Entry in pairs( Rows ) do
            if Opt == S.V then
                Entry.Text.TextColor3 = ACCENT_BRIGHT;
                Entry.Text.Font = FTB;
                Entry.Acc.Visible = false;
            elseif Opt == S.H then
                Entry.Text.TextColor3 = Color3.fromRGB( 221, 221, 221 );
                Entry.Text.Font = FT;
                Entry.Acc.Visible = true;
            else
                Entry.Text.TextColor3 = Color3.fromRGB( 184, 184, 184 );
                Entry.Text.Font = FT;
                Entry.Acc.Visible = false;
            end;
        end;

        Tw : Create( List, TweenInfo.new( 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out ), {
            Size = S.Op and UDim2.new( 1, 0, 0, #Options * 16 ) or UDim2.new( 1, 0, 0, 0 );
        } ) : Play();
        List.Visible = S.Op or List.Size.Y.Offset > 0;
    end;

    Trig.MouseButton1Click : Connect( function() S.Op = not S.Op; Refresh(); end );
    Refresh();
    return { Container = Box; Set = function( V ) S.V = V; TT.Text = V; Refresh(); end; Get = function() return S.V; end; };
end;

local function Divider( Parent )
    local D = C( "Frame", {
        BackgroundColor3 = Color3.fromRGB( 44, 44, 44 );
        BorderSizePixel = 0;
        Size = UDim2.new( 1, 0, 0, 1 );
        Parent = Parent;
    } );
    GR( D, {
        { 0, Color3.fromRGB( 22, 22, 22 ) };
        { 0.2, Color3.fromRGB( 44, 44, 44 ) };
        { 0.5, Color3.fromRGB( 56, 56, 56 ) };
        { 0.8, Color3.fromRGB( 44, 44, 44 ) };
        { 1, Color3.fromRGB( 22, 22, 22 ) };
    }, 0 );
    return D;
end;

local function SectionLabel( Parent, Text )
    return C( "TextLabel", {
        BackgroundTransparency = 1;
        Size = UDim2.new( 1, 0, 0, 11 );
        Text = string.upper( Text );
        TextColor3 = Color3.fromRGB( 120, 120, 120 );
        TextSize = 9;
        Font = FT;
        TextXAlignment = Enum.TextXAlignment.Left;
        Parent = Parent;
    } );
end;

local function Heading( Parent, Text )
    local H = C( "Frame", {
        BackgroundTransparency = 1;
        Size = UDim2.new( 1, 0, 0, 14 );
        Parent = Parent;
    } );

    local Bar = C( "Frame", {
        BackgroundColor3 = ACCENT_BRIGHT;
        BorderSizePixel = 0;
        Position = O2( 0, 1.5 );
        Size = O2( 3, 11 );
        Parent = H;
    } );
    CR( Bar, 1 );
    GR( Bar, { { 0, ACCENT_BRIGHT }; { 1, ACCENT_DIM }; }, 90 );

    C( "TextLabel", {
        BackgroundTransparency = 1;
        Position = O2( 8, 0 );
        Size = UDim2.new( 1, -8, 1, 0 );
        Text = Text;
        TextColor3 = TX_PRIMARY;
        TextSize = 10;
        Font = FTB;
        TextXAlignment = Enum.TextXAlignment.Left;
        Parent = H;
    } );

    return H;
end;

local function Tab( Parent, Text, Small, Order, Click )
    local S = { A = false, H = false };

    local T = C( "TextButton", {
        BorderSizePixel = 0;
        Size = O2( 55, Small and 20 or 22 );
        Text = "";
        AutoButtonColor = false;
        LayoutOrder = Order;
        Parent = Parent;
    } );

    local Fill = C( "Frame", {
        BackgroundTransparency = 0;
        Size = UDim2.new( 1, 0, 1, 0 );
        Parent = T;
    } );
    local FG = GR( Fill, { { 0, Color3.fromRGB( 28, 28, 28 ) }; { 1, Color3.fromRGB( 20, 20, 20 ) }; }, 90 );

    local Lbl = C( "TextLabel", {
        BackgroundTransparency = 1;
        Size = UDim2.new( 1, 0, 1, 0 );
        Text = Text;
        TextColor3 = TX_MUTED;
        TextSize = Small and 9 or 10;
        Font = FT;
        Parent = T;
    } );

    local TopB = C( "Frame", {
        BackgroundColor3 = B_FAINT;
        BorderSizePixel = 0;
        Size = UDim2.new( 1, 0, 0, 1 );
        Parent = T;
    } );

    -- When active, this fills the panel-divider line under the tab
    local Tail = C( "Frame", {
        BackgroundColor3 = Color3.fromRGB( 30, 30, 30 );
        BorderSizePixel = 0;
        Position = UDim2.new( 0, 0, 1, 0 );
        Size = UDim2.new( 1, 0, 0, 1 );
        Visible = false;
        ZIndex = 6;
        Parent = T;
    } );

    local function Refresh()
        local Pad = Small and 16 or 22;
        T.Size = O2( Lbl.TextBounds.X + Pad, Small and 20 or 22 );

        if S.A then
            FG.Color = ColorSequence.new( {
                ColorSequenceKeypoint.new( 0, Color3.fromRGB( 42, 42, 42 ) );
                ColorSequenceKeypoint.new( 0.6, Color3.fromRGB( 32, 32, 32 ) );
                ColorSequenceKeypoint.new( 1, Color3.fromRGB( 28, 28, 28 ) );
            } );
            Lbl.TextColor3 = Color3.fromRGB( 224, 224, 224 );
            Lbl.Font = FTB;
            TopB.BackgroundColor3 = ACCENT;
            Tail.Visible = true;
            T.ZIndex = 3;
        elseif S.H then
            FG.Color = ColorSequence.new( {
                ColorSequenceKeypoint.new( 0, Color3.fromRGB( 34, 34, 34 ) );
                ColorSequenceKeypoint.new( 1, Color3.fromRGB( 26, 26, 26 ) );
            } );
            Lbl.TextColor3 = TX_HOVER;
            Lbl.Font = FT;
            TopB.BackgroundColor3 = Color3.fromRGB( 64, 64, 64 );
            Tail.Visible = false;
            T.ZIndex = 1;
        else
            FG.Color = ColorSequence.new( {
                ColorSequenceKeypoint.new( 0, Color3.fromRGB( 28, 28, 28 ) );
                ColorSequenceKeypoint.new( 1, Color3.fromRGB( 20, 20, 20 ) );
            } );
            Lbl.TextColor3 = TX_MUTED;
            Lbl.Font = FT;
            TopB.BackgroundColor3 = B_FAINT;
            Tail.Visible = false;
            T.ZIndex = 1;
        end;
    end;

    T.MouseButton1Click : Connect( function() if Click then Click(); end; end );
    T.MouseEnter : Connect( function() S.H = true; Refresh(); end );
    T.MouseLeave : Connect( function() S.H = false; Refresh(); end );

    Refresh();
    task.defer( Refresh );

    return { Tab = T; SetActive = function( V ) S.A = V; Refresh(); end; };
end;

-- ── Page wrapper ────────────────────────────────────────────────────────────

local Page = { };
Page.__index = Page;

function Page : Checkbox( L, D, CB ) return Checkbox( self.Frame, L, D, CB ); end;
function Page : Slider( L, D, CB ) return Slider( self.Frame, L, D, CB ); end;
function Page : Dropdown( O, D, CB ) return Dropdown( self.Frame, O, D, CB ); end;
function Page : Divider() return Divider( self.Frame ); end;
function Page : Label( T ) return SectionLabel( self.Frame, T ); end;

-- ── Interface ───────────────────────────────────────────────────────────────

local Interface = { };
Interface.__index = Interface;

function Interface.new( Title )
    Title = Title or "juanita****.club";

    local SG = C( "ScreenGui", {
        Name = "juanita_club";
        ResetOnSpawn = false;
        IgnoreGuiInset = true;
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
        Parent = CG;
    } );

    local Win = C( "Frame", {
        BackgroundColor3 = BG_WIN;
        BorderSizePixel = 0;
        AnchorPoint = Vector2.new( 0.5, 0.5 );
        Position = UDim2.new( 0.5, 0, 0.5, 0 );
        Size = O2( 400, 260 );
        ClipsDescendants = true;
        Parent = SG;
    } );
    CR( Win, 4 );
    ST( Win, B_EDGE );

    -- Title bar
    local TB = C( "Frame", {
        BorderSizePixel = 0;
        Size = UDim2.new( 1, 0, 0, 22 );
        Parent = Win;
    } );
    GR( TB, {
        { 0, Color3.fromRGB( 42, 42, 42 ) };
        { 0.5, Color3.fromRGB( 31, 31, 31 ) };
        { 1, Color3.fromRGB( 26, 26, 26 ) };
    }, 90 );

    C( "Frame", {
        BackgroundColor3 = Color3.fromRGB( 10, 10, 10 );
        BorderSizePixel = 0;
        Size = UDim2.new( 1, 0, 0, 1 );
        Position = UDim2.new( 0, 0, 1, -1 );
        Parent = TB;
    } );

    local Mark = C( "Frame", {
        BackgroundColor3 = ACCENT_BRIGHT;
        BorderSizePixel = 0;
        Position = O2( 9, 6 );
        Size = O2( 9, 11 );
        Parent = TB;
    } );
    CR( Mark, 2 );
    GR( Mark, { { 0, ACCENT_BRIGHT }; { 1, ACCENT_DIM }; }, 90 );

    C( "TextLabel", {
        BackgroundTransparency = 1;
        Position = O2( 22, 0 );
        Size = UDim2.new( 1, -80, 1, 0 );
        Text = Title;
        TextColor3 = TX_PRIMARY;
        TextSize = 10;
        Font = FTM;
        TextXAlignment = Enum.TextXAlignment.Left;
        Parent = TB;
    } );

    local TBtn = C( "Frame", {
        BackgroundTransparency = 1;
        Position = UDim2.new( 1, -38, 0, 5 );
        Size = O2( 34, 12 );
        Parent = TB;
    } );

    local Min = C( "TextButton", {
        BackgroundColor3 = Color3.fromRGB( 46, 46, 46 );
        BorderSizePixel = 0;
        Size = O2( 16, 12 );
        Text = "-";
        TextColor3 = Color3.fromRGB( 144, 144, 144 );
        TextSize = 10;
        Font = FT;
        AutoButtonColor = false;
        Parent = TBtn;
    } );
    CR( Min, 2 );
    ST( Min, Color3.fromRGB( 72, 72, 72 ) );

    local Cls = C( "TextButton", {
        BackgroundColor3 = Color3.fromRGB( 146, 32, 32 );
        BorderSizePixel = 0;
        Position = O2( 18, 0 );
        Size = O2( 16, 12 );
        Text = "x";
        TextColor3 = Color3.fromRGB( 238, 238, 238 );
        TextSize = 9;
        Font = FT;
        AutoButtonColor = false;
        Parent = TBtn;
    } );
    CR( Cls, 2 );
    ST( Cls, Color3.fromRGB( 106, 16, 16 ) );

    -- Main tab strip
    local TS = C( "Frame", {
        BorderSizePixel = 0;
        Position = O2( 0, 22 );
        Size = UDim2.new( 1, 0, 0, 26 );
        Parent = Win;
    } );
    GR( TS, { { 0, Color3.fromRGB( 22, 22, 22 ) }; { 1, Color3.fromRGB( 18, 18, 18 ) }; }, 90 );

    C( "Frame", {
        BackgroundColor3 = Color3.fromRGB( 46, 46, 46 );
        BorderSizePixel = 0;
        Size = UDim2.new( 1, 0, 0, 1 );
        Position = UDim2.new( 0, 0, 1, -1 );
        Parent = TS;
    } );

    local THolder = C( "Frame", {
        BackgroundTransparency = 1;
        Position = O2( 6, 4 );
        Size = UDim2.new( 1, -12, 1, -4 );
        Parent = TS;
    } );
    C( "UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Padding = O( 2 );
        VerticalAlignment = Enum.VerticalAlignment.Bottom;
        Parent = THolder;
    } );

    -- Body
    local Body = C( "Frame", {
        BackgroundColor3 = BG_WIN;
        BorderSizePixel = 0;
        Position = O2( 0, 48 );
        Size = UDim2.new( 1, 0, 0, 200 );
        Parent = Win;
    } );

    local LP = C( "Frame", {
        BackgroundColor3 = BG_WIN;
        BorderSizePixel = 0;
        Size = O2( PANEL_W, 200 );
        Parent = Body;
    } );

    local LI = C( "Frame", {
        BackgroundTransparency = 1;
        Position = O2( 8, 8 );
        Size = O2( PANEL_W - 16, 0 );
        AutomaticSize = Enum.AutomaticSize.Y;
        Parent = LP;
    } );

    local Div = C( "Frame", {
        BackgroundColor3 = Color3.fromRGB( 32, 32, 32 );
        BorderSizePixel = 0;
        Position = O2( PANEL_W, 0 );
        Size = O2( 1, 200 );
        Parent = Body;
    } );

    local RP = C( "Frame", {
        BackgroundColor3 = BG_WIN;
        BorderSizePixel = 0;
        Position = O2( PANEL_W + 1, 0 );
        Size = O2( RIGHT_W, 200 );
        Parent = Body;
    } );

    -- Right: sub-tab strip + content, both positioned manually
    local RStrip = C( "Frame", {
        BackgroundTransparency = 1;
        Position = O2( 8, 8 );
        Size = O2( RIGHT_W - 16, 22 );
        Parent = RP;
    } );
    C( "Frame", {
        BackgroundColor3 = B_FAINT;
        BorderSizePixel = 0;
        Size = UDim2.new( 1, 0, 0, 1 );
        Position = UDim2.new( 0, 0, 1, -1 );
        Parent = RStrip;
    } );
    C( "UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Padding = O( 2 );
        VerticalAlignment = Enum.VerticalAlignment.Bottom;
        Parent = RStrip;
    } );

    local RContent = C( "Frame", {
        BackgroundTransparency = 1;
        Position = O2( 8, 36 );
        Size = O2( RIGHT_W - 16, 0 );
        Parent = RP;
    } );

    -- Footer
    local FT_ = C( "Frame", {
        BorderSizePixel = 0;
        Position = UDim2.new( 0, 0, 1, -18 );
        Size = UDim2.new( 1, 0, 0, 18 );
        Parent = Win;
    } );
    GR( FT_, { { 0, Color3.fromRGB( 18, 18, 18 ) }; { 1, Color3.fromRGB( 14, 14, 14 ) }; }, 90 );
    C( "Frame", {
        BackgroundColor3 = Color3.fromRGB( 30, 30, 30 );
        BorderSizePixel = 0;
        Size = UDim2.new( 1, 0, 0, 1 );
        Parent = FT_;
    } );

    C( "TextLabel", {
        BackgroundTransparency = 1;
        Position = O2( 10, 0 );
        Size = UDim2.new( 1, -20, 1, 0 );
        Text = "build 2.4.1";
        TextColor3 = TX_FAINT;
        TextSize = 8;
        Font = FT;
        TextXAlignment = Enum.TextXAlignment.Left;
        Parent = FT_;
    } );

    local SD = C( "Frame", {
        BackgroundColor3 = Color3.fromRGB( 46, 204, 85 );
        BorderSizePixel = 0;
        AnchorPoint = Vector2.new( 1, 0.5 );
        Position = UDim2.new( 1, -50, 0.5, 0 );
        Size = O2( 4, 4 );
        Parent = FT_;
    } );
    CR( SD, 100 );

    C( "TextLabel", {
        BackgroundTransparency = 1;
        AnchorPoint = Vector2.new( 1, 0.5 );
        Position = UDim2.new( 1, -8, 0.5, 0 );
        Size = O2( 36, 11 );
        Text = "CONNECTED";
        TextColor3 = TX_FAINT;
        TextSize = 8;
        Font = FT;
        TextXAlignment = Enum.TextXAlignment.Right;
        Parent = FT_;
    } );

    -- Drag
    local Drag = { A = false, MX = 0, MY = 0, PX = 0, PY = 0 };

    TB.InputBegan : Connect( function( Inp )
        if Inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return; end;
        Drag.A = true;
        Drag.MX = Inp.Position.X;
        Drag.MY = Inp.Position.Y;
        Drag.PX = Win.Position.X.Offset;
        Drag.PY = Win.Position.Y.Offset;
    end );

    UIS.InputChanged : Connect( function( Inp )
        if not Drag.A then return; end;
        if Inp.UserInputType ~= Enum.UserInputType.MouseMovement then return; end;
        Win.Position = UDim2.new(
            0.5, Drag.PX + ( Inp.Position.X - Drag.MX ),
            0.5, Drag.PY + ( Inp.Position.Y - Drag.MY )
        );
    end );

    UIS.InputEnded : Connect( function( Inp )
        if Inp.UserInputType == Enum.UserInputType.MouseButton1 then Drag.A = false; end;
    end );

    Cls.MouseButton1Click : Connect( function() SG : Destroy(); end );
    Min.MouseButton1Click : Connect( function() Win.Visible = not Win.Visible; end );

    -- State
    local LPages, LTabs = { }, { };
    local RPages, RTabs = { }, { };

    local API = setmetatable( {
        ScreenGui = SG;
        Window = Win;
        Heading = nil;
    }, Interface );

    function API : AddLeftTab( Name )
        if LPages[ Name ] then return LPages[ Name ]; end;

        local F = C( "Frame", {
            BackgroundTransparency = 1;
            Size = O2( PANEL_W - 16, 0 );
            AutomaticSize = Enum.AutomaticSize.Y;
            LayoutOrder = 1;
            Visible = false;
            Parent = LI;
        } );

        C( "UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder;
            Padding = O( 4 );
            Parent = F;
        } );

        local T = Tab( THolder, Name, false, #LPages + 1, function()
            API : SelectLeftTab( Name );
        end );

        local P = setmetatable( { Frame = F }, Page );
        LPages[ Name ] = P; LTabs[ Name ] = T;

        -- Attach the tab order in LI so the heading appears first
        F.LayoutOrder = 2;

        return P;
    end;

    function API : SelectLeftTab( Name )
        for TN, P in pairs( LPages ) do P.Frame.Visible = ( TN == Name ); end;
        for TN, T in pairs( LTabs ) do T : SetActive( TN == Name ); end;

        if API.Heading then API.Heading : Destroy(); end;

        local Hold = C( "Frame", {
            BackgroundTransparency = 1;
            Size = UDim2.new( 1, 0, 0, 14 );
            LayoutOrder = 1;
            Parent = LI;
        } );

        API.Heading = Heading( Hold, Name );
        API.Heading.Size = UDim2.new( 1, 0, 1, 0 );
    end;

    function API : AddRightTab( Name )
        if RPages[ Name ] then return RPages[ Name ]; end;

        local F = C( "Frame", {
            BackgroundTransparency = 1;
            Size = O2( RIGHT_W - 16, 0 );
            Position = O2( 0, 0 );
            AutomaticSize = Enum.AutomaticSize.Y;
            Visible = false;
            Parent = RContent;
        } );

        C( "UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder;
            Padding = O( 4 );
            Parent = F;
        } );

        local T = Tab( RStrip, Name, true, #RPages + 1, function()
            API : SelectRightTab( Name );
        end );

        local P = setmetatable( { Frame = F }, Page );
        RPages[ Name ] = P; RTabs[ Name ] = T;

        return P;
    end;

    function API : SelectRightTab( Name )
        for TN, P in pairs( RPages ) do P.Frame.Visible = ( TN == Name ); end;
        for TN, T in pairs( RTabs ) do T : SetActive( TN == Name ); end;
    end;

    -- Fit-to-content, deferred so AbsoluteSize settles
    task.spawn( function()
        task.wait( 0.1 );

        local LeftH, RightH = 0, 0;

        for _, P in pairs( LPages ) do
            LeftH = math.max( LeftH, P.Frame.AbsoluteSize.Y );
        end;
        for _, P in pairs( RPages ) do
            RightH = math.max( RightH, P.Frame.AbsoluteSize.Y );
        end;

        local BodyH = math.max( LeftH + 16, RightH + 44, 140 );

        Body.Size = UDim2.new( 1, 0, 0, BodyH );
        LP.Size = O2( PANEL_W, BodyH );
        Div.Size = O2( 1, BodyH );
        RP.Size = O2( RIGHT_W, BodyH );

        Win.Size = O2( 400, 22 + 26 + BodyH + 18 );
    end );

    return API;
end;

return Interface;
