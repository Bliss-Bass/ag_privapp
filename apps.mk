PRODUCT_PACKAGES += \
	StarlightEmail \
	StarlightPDFViewer \
	StarlightContacts \
	StarlightFax \
	DroidifyEnterprise \


PRODUCT_COPY_FILES += vendor/ag_privapp/permissions/ag-priv-app-permissions.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/ag-priv-app-permissions.xml

PRODUCT_COPY_FILES += vendor/ag_privapp/default-permissions/ag-priv-default-permissions.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/default-permissions/ag-priv-default-permissions.xml

PRODUCT_COPY_FILES += vendor/ag_privapp/default-whitelist/whitelist-app.ag-priv.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/whitelist-app.ag-priv.xml

