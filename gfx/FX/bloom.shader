Includes = {
	"constants.fxh"
	"standardfuncsgfx.fxh"
	"posteffect_base.fxh"
}

PixelShader =
{
	Samplers =
	{
		BloomSource =
		{
			Index = 0
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			AddressU = "Clamp"
			AddressV = "Clamp"
		}
	}
}


VertexStruct VS_INPUT
{
    int2 position	: POSITION;
};

VertexStruct VS_OUTPUT_BLOOM
{
    float4 position			: PDX_POSITION;
	float2 uvBloom			: TEXCOORD0;
	float4 uvBloom2_0		: TEXCOORD1;
	float4 uvBloom2_1		: TEXCOORD2;
	float4 uvBloom2_2		: TEXCOORD3;
	float4 uvBloom2_3		: TEXCOORD4;
};


ConstantBuffer( 2, 39 )
{
	float2 InvBloomSize;
	float Axis;
	float Weight0;
	float4 Weights;
	float4 Offsets;
};


VertexShader =
{
	MainCode VertexShader
	[[
		VS_OUTPUT_BLOOM main( const VS_INPUT VertexIn )
		{
			VS_OUTPUT_BLOOM VertexOut;
			VertexOut.position = float4( VertexIn.position, 0.0f, 1.0f );
		
			VertexOut.uvBloom = ( VertexIn.position + 1.0f ) * 0.5f;
			VertexOut.uvBloom.y = 1.0f - VertexOut.uvBloom.y;
		
			float2 vInvSize = InvBloomSize;
			
		#ifdef PDX_DIRECTX_9 // Half pixel offset
			VertexOut.position.xy += float2( -vInvSize.x, vInvSize.y );
		#endif
		
			float2 vAxisOffset = vInvSize * float2( Axis, 1.0 - Axis );
		
			VertexOut.uvBloom2_0 = float4( 
					VertexOut.uvBloom + vAxisOffset * Offsets[0], 
					VertexOut.uvBloom - vAxisOffset * Offsets[0] );
			VertexOut.uvBloom2_1 = float4( 
					VertexOut.uvBloom + vAxisOffset * Offsets[1], 
					VertexOut.uvBloom - vAxisOffset * Offsets[1] );
			VertexOut.uvBloom2_2 = float4( 
					VertexOut.uvBloom + vAxisOffset * Offsets[2], 
					VertexOut.uvBloom - vAxisOffset * Offsets[2] );
			VertexOut.uvBloom2_3 = float4( 
					VertexOut.uvBloom + vAxisOffset * Offsets[3], 
					VertexOut.uvBloom - vAxisOffset * Offsets[3] );
		
			return VertexOut;
		}
	]]
}

PixelShader =
{
	MainCode PixelShader
	[[
		float4 main( VS_OUTPUT_BLOOM Input ) : PDX_COLOR
		{
			float3 color = tex2Dlod0( BloomSource, Input.uvBloom ).rgb * Weight0;
			return float4(color, 1.0);
		}
	]]
	
	MainCode PixelShaderAlpha
	[[
		float4 main( VS_OUTPUT_BLOOM Input ) : PDX_COLOR
		{
			return float4(0.0, 0.0, 0.0, 0.0);
		}
	]]
}


BlendState BlendState
{
	BlendEnable = no
}


Effect bloom
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
}

Effect bloom_alpha
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShaderAlpha"
}

