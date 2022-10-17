Assets {
  Id: 101697734561938786
  Name: "Custom Frosted Glass - Castle Windows Tall"
  PlatformAssetType: 13
  SerializationVersion: 119
  CustomMaterialAsset {
    BaseMaterialId: 16630259605395466384
    ParameterOverrides {
      Overrides {
        Name: "Roughness"
        Float: 0.548862934
      }
      Overrides {
        Name: "Clarity"
        Float: 1
      }
      Overrides {
        Name: "Thickness"
        Float: 1
      }
      Overrides {
        Name: "Specular"
        Float: 0.16664198
      }
      Overrides {
        Name: "color"
        Color {
          G: 0.348079324
          B: 0.72
          A: 1
        }
      }
    }
    Assets {
      Id: 16630259605395466384
      Name: "Frosted Glass"
      PlatformAssetType: 2
      PrimaryAsset {
        AssetType: "MaterialAssetRef"
        AssetId: "fxma_frosted_glass"
      }
    }
  }
}
