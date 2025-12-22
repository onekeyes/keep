from datetime import datetime
from typing import Optional

from pydantic import ConfigDict
from sqlalchemy import UniqueConstraint
from sqlmodel import Column, Field, SQLModel, TEXT


class Action(SQLModel, table=True):
    __table_args__ = (UniqueConstraint("tenant_id", "name", "use"),)

    id: str = Field(default=None, primary_key=True)
    tenant_id: str = Field(foreign_key="tenant.id")
    use: str
    name: str
    description: Optional[str] = None
    action_raw: str = Field(sa_column=Column(TEXT))
    installed_by: str
    installation_time: datetime
   
    model_config = ConfigDict(from_attributes=True)
