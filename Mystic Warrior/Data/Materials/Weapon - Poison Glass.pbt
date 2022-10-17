Assets {
  Id: 15501544634298572828
  Name: "Weapon - Poison Glass"
  PlatformAssetType: 13
  SerializationVersion: 119
  CustomMaterialAsset {
    BaseMaterialId: 16845241941935487831
    ParameterOverrides {
      Overrides {
        Name: "color"
        Color {
          G: 4
          B: 0.0264911652
          A: 1
        }
      }
      Overrides {
        Name: "Metallic"
        Float: 0.409874201
      }
      Overrides {
        Name: "Specular"
        Float: 0.398291767
      }
      Overrides {
        Name: "Clarity"
        Float: 0.265093535
      }
      Overrides {
        Name: "Thickness"
        Float: 3
      }
    }
    Assets {
      Id: 16845241941935487831
      Name: "Glass 01 (no distortion)"
      PlatformAssetType: 2
      PrimaryAsset {
        AssetType: "MaterialAssetRef"
        AssetId: "mi_basic_glass_001"
      }
    }
  }
}
