import ProvidersPage from "./providers/page";

import { getTranslations } from 'next-intl/server';

export async function generateMetadata() {
  const t = await getTranslations('pages.keep');
  
  return {
    title: t('title'),
    description: t('description'),
  };
}

export default ProvidersPage;
