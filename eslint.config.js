import baseConfig from '@kitiumai/config/eslint.config.base.js';

export default [
  ...baseConfig,
  {
    ignores: [
      '**/*.cjs',
      '.storybook/**',
      'dist/**',
      'node_modules/**',
      'services/**/*.config.js',
      '*.config.js',
      '*.config.ts',
      'scripts/**',
    ],
  },
  {
    files: ['src/types.ts', 'src/**/*.ts'],
    rules: {
      '@typescript-eslint/naming-convention': [
        'error',
        {
          selector: 'default',
          format: ['camelCase'],
        },
        {
          selector: 'variable',
          format: ['camelCase', 'UPPER_CASE'],
        },
        {
          selector: 'parameter',
          format: ['camelCase'],
          leadingUnderscore: 'allow',
        },
        {
          selector: 'memberLike',
          format: ['camelCase'],
        },
        {
          selector: 'typeLike',
          format: ['PascalCase'],
        },
        {
          selector: 'property',
          format: null,
          filter: {
            regex: '^(container_name|depends_on|start_period|API_URL)$',
            match: true,
          },
        },
      ],
    },
  },
  {
    files: ['services/api/src/**/*.ts'],
    rules: {
      '@typescript-eslint/no-explicit-any': 'off',
    },
  },
];
