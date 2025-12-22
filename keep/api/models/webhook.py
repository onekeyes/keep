from pydantic.v1 import BaseModel


class WebhookSettings(BaseModel):
    webhookApi: str
    apiKey: str
    modelSchema: dict


class ProviderWebhookSettings(BaseModel):
    webhookDescription: str | None = None
    webhookTemplate: str
    webhookMarkdown: str | None = None
