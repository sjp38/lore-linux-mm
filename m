Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 099E6C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 10:28:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A7A942075C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 10:28:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A7A942075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3AD2C8E0014; Mon, 11 Mar 2019 06:28:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 333BF8E0002; Mon, 11 Mar 2019 06:28:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D5698E0014; Mon, 11 Mar 2019 06:28:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id E0B728E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 06:28:39 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id f142so2856783vkd.18
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 03:28:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=j8MXj9/BADA2UJLgmBJpdw59jZpQ5TDruV8vMVMKy/8=;
        b=K90WpzI/gLoPPUo8TlE5V/9LmakxTCuSnbaN3sjJJ2lir5jBqoVnY/mnFNzbJHDWKm
         qQtJkG3TLUKx1E84kWrhIU7GkRTkAbfxRJAe+h6WhZVbq/IODbRGHTYIoR213JEKFUcr
         jT2/b3kspp6MqyorRuRH+8EdsRrRY1vHw4m7JFzauxxyiQLKLBEbbL33bcZ47GNBdEpd
         mOnNGw2gFpZpD/DuPE3rCqacsGmdBbrwovlknNSKToUjSmySEuywb4q0HUMG+gJf+ZEL
         SARr+E8hjIyJp9ybNUzpJtgWROp2KwLu6/MhWxM9/Jsyt+udyWwtecfRX/67UWCEq0t+
         UWMA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: APjAAAXRUNkumzMSVQ50FHGckdjW5IcB4hh7mxQ4dxHlesJQt3Qfkozr
	DFXwiVBy4E4kIYvFTW82gmWhI3nC7wXkCWV5NLyja7hzkAkVp5SYsZw+C01zga1h97UjxTxysC2
	bNL32gjOkVfxdARttc286aCvHeGynAB/U13aTO4/F1Vs5yiWl4UEEZvU7ZuVhMFlkug==
X-Received: by 2002:a1f:8889:: with SMTP id k131mr10735675vkd.16.1552300119503;
        Mon, 11 Mar 2019 03:28:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwjGF0BmVXjrWpLeHoWHJaAB+UG/khBhTm8TeSEMJZcTjLyPxkHRaY3drJDcmucso0O/6cl
X-Received: by 2002:a1f:8889:: with SMTP id k131mr10735639vkd.16.1552300118245;
        Mon, 11 Mar 2019 03:28:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552300118; cv=none;
        d=google.com; s=arc-20160816;
        b=JUu03JJ/rvo4NTxVfO7IEy3v6+KhHCy+sDDp/9ecmaIiw4fMlAnjZETq41xf359KuB
         ps3cHFUmXuuUTDztZTQm5flw/dFj6fzFQNtv8Wlf2LCAHg+nZZJvTdwuflov3k3x56ow
         BXXhVIw9/yjYjjWCyh7r/yrZmuQxyLbtMoArYeeTD/YzUq7JyvToz+EEfQB9ODb8ADia
         CDnbJodc2gf33k/lKqk/Tlo0iFPHGAOK+5HbktDxloJWEME4jruUYoSkmh3MEQ/EKK0/
         CdFxwjST2LkFSiB1Otp3O9rez2SLkxL9VESpld2+uhcge+WZtmmHi0Gw7BIrr25QaSO/
         851Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=j8MXj9/BADA2UJLgmBJpdw59jZpQ5TDruV8vMVMKy/8=;
        b=CCGlrs8E0k/QDYDhu3jFqzh3UQQrXtE4RLMHRx3NOK4z6zDetns+sT9U4m0UE57yN/
         tu38GSwAkOFKbJdAcK0ttoFFrtKGiWyOr+67mMBnxu+jz0IUawxEXslHYr4s7qDOHHqt
         D1s4CJH1XZHDTLjJk9VyiuOYbZFD4ZFe/OJw9AuZqtACezISxC1ix6tk7Lt3UKHa81D/
         OraEXASPjPdop11ogQm6MMg//DJSXWkx/BqWSgxMEfvjVV/AweiIZCOrxkx9LqkvT/Jk
         JS8u2i46Sy8K0gNst0ATOReHLIBCm87LKtBHio9jICRq2qYmh1raq3G7iOV1UDD8KzE7
         LgyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id o26si919338uar.200.2019.03.11.03.28.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 03:28:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS412-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id A8427AC17551C24E76BC;
	Mon, 11 Mar 2019 18:28:33 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS412-HUB.china.huawei.com
 (10.3.19.212) with Microsoft SMTP Server id 14.3.408.0; Mon, 11 Mar 2019
 18:28:30 +0800
Date: Mon, 11 Mar 2019 10:28:20 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Keith Busch <keith.busch@intel.com>
CC: <linux-kernel@vger.kernel.org>, <linux-acpi@vger.kernel.org>,
	<linux-mm@kvack.org>, <linux-api@vger.kernel.org>, Greg Kroah-Hartman
	<gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, "Dave
 Hansen" <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCHv7 03/10] acpi/hmat: Parse and report heterogeneous
 memory
Message-ID: <20190311102820.00000f2c@huawei.com>
In-Reply-To: <20190227225038.20438-4-keith.busch@intel.com>
References: <20190227225038.20438-1-keith.busch@intel.com>
	<20190227225038.20438-4-keith.busch@intel.com>
Organization: Huawei
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; i686-w64-mingw32)
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.202.226.61]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 27 Feb 2019 15:50:31 -0700
Keith Busch <keith.busch@intel.com> wrote:

> Systems may provide different memory types and export this information
> in the ACPI Heterogeneous Memory Attribute Table (HMAT). Parse these
> tables provided by the platform and report the memory access and caching
> attributes to the kernel messages.
> 
> Reviewed-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> Signed-off-by: Keith Busch <keith.busch@intel.com>
Hi Keith

A few trivial comments in this one. All stuff we can fix if a firmware
runs into the limits of representation.

One other question that comes to mind is:
The move to picoseconds was perhaps optimistic on the part of the
ACPI spec, but do we want to go for future proofing and go with them?
Costs us a few more zeros in a sysfs file after all.  Internal storage
could stay at nano seconds perhaps.

All small things though so either way...

Reviewed-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>

> ---
>  drivers/acpi/Kconfig       |   1 +
>  drivers/acpi/Makefile      |   1 +
>  drivers/acpi/hmat/Kconfig  |   7 ++
>  drivers/acpi/hmat/Makefile |   1 +
>  drivers/acpi/hmat/hmat.c   | 237 +++++++++++++++++++++++++++++++++++++++++++++
>  5 files changed, 247 insertions(+)
>  create mode 100644 drivers/acpi/hmat/Kconfig
>  create mode 100644 drivers/acpi/hmat/Makefile
>  create mode 100644 drivers/acpi/hmat/hmat.c
> 
> diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
> index 4e015c77e48e..283ee94224c6 100644
> --- a/drivers/acpi/Kconfig
> +++ b/drivers/acpi/Kconfig
> @@ -475,6 +475,7 @@ config ACPI_REDUCED_HARDWARE_ONLY
>  	  If you are unsure what to do, do not enable this option.
>  
>  source "drivers/acpi/nfit/Kconfig"
> +source "drivers/acpi/hmat/Kconfig"
>  
>  source "drivers/acpi/apei/Kconfig"
>  source "drivers/acpi/dptf/Kconfig"
> diff --git a/drivers/acpi/Makefile b/drivers/acpi/Makefile
> index bb857421c2e8..5d361e4e3405 100644
> --- a/drivers/acpi/Makefile
> +++ b/drivers/acpi/Makefile
> @@ -80,6 +80,7 @@ obj-$(CONFIG_ACPI_PROCESSOR)	+= processor.o
>  obj-$(CONFIG_ACPI)		+= container.o
>  obj-$(CONFIG_ACPI_THERMAL)	+= thermal.o
>  obj-$(CONFIG_ACPI_NFIT)		+= nfit/
> +obj-$(CONFIG_ACPI_HMAT)		+= hmat/
>  obj-$(CONFIG_ACPI)		+= acpi_memhotplug.o
>  obj-$(CONFIG_ACPI_HOTPLUG_IOAPIC) += ioapic.o
>  obj-$(CONFIG_ACPI_BATTERY)	+= battery.o
> diff --git a/drivers/acpi/hmat/Kconfig b/drivers/acpi/hmat/Kconfig
> new file mode 100644
> index 000000000000..2f7111b7af62
> --- /dev/null
> +++ b/drivers/acpi/hmat/Kconfig
> @@ -0,0 +1,7 @@
> +# SPDX-License-Identifier: GPL-2.0
> +config ACPI_HMAT
> +	bool "ACPI Heterogeneous Memory Attribute Table Support"
> +	depends on ACPI_NUMA
> +	help
> +	 If set, this option has the kernel parse and report the
> +	 platform's ACPI HMAT (Heterogeneous Memory Attributes Table).
> diff --git a/drivers/acpi/hmat/Makefile b/drivers/acpi/hmat/Makefile
> new file mode 100644
> index 000000000000..e909051d3d00
> --- /dev/null
> +++ b/drivers/acpi/hmat/Makefile
> @@ -0,0 +1 @@
> +obj-$(CONFIG_ACPI_HMAT) := hmat.o
> diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
> new file mode 100644
> index 000000000000..99f711420f6d
> --- /dev/null
> +++ b/drivers/acpi/hmat/hmat.c
> @@ -0,0 +1,237 @@
> +// SPDX-License-Identifier: GPL-2.0
> +/*
> + * Copyright (c) 2019, Intel Corporation.
> + *
> + * Heterogeneous Memory Attributes Table (HMAT) representation
> + *
> + * This program parses and reports the platform's HMAT tables, and registers
> + * the applicable attributes with the node's interfaces.
> + */
> +
> +#include <linux/acpi.h>
> +#include <linux/bitops.h>
> +#include <linux/device.h>
> +#include <linux/init.h>
> +#include <linux/list.h>
> +#include <linux/node.h>
> +#include <linux/sysfs.h>
> +
> +static __initdata u8 hmat_revision;
> +
> +static __init const char *hmat_data_type(u8 type)
> +{
> +	switch (type) {
> +	case ACPI_HMAT_ACCESS_LATENCY:
> +		return "Access Latency";
> +	case ACPI_HMAT_READ_LATENCY:
> +		return "Read Latency";
> +	case ACPI_HMAT_WRITE_LATENCY:
> +		return "Write Latency";
> +	case ACPI_HMAT_ACCESS_BANDWIDTH:
> +		return "Access Bandwidth";
> +	case ACPI_HMAT_READ_BANDWIDTH:
> +		return "Read Bandwidth";
> +	case ACPI_HMAT_WRITE_BANDWIDTH:
> +		return "Write Bandwidth";
> +	default:
> +		return "Reserved";
> +	}
> +}
> +
> +static __init const char *hmat_data_type_suffix(u8 type)
> +{
> +	switch (type) {
> +	case ACPI_HMAT_ACCESS_LATENCY:
> +	case ACPI_HMAT_READ_LATENCY:
> +	case ACPI_HMAT_WRITE_LATENCY:
> +		return " nsec";
> +	case ACPI_HMAT_ACCESS_BANDWIDTH:
> +	case ACPI_HMAT_READ_BANDWIDTH:
> +	case ACPI_HMAT_WRITE_BANDWIDTH:
> +		return " MB/s";
> +	default:
> +		return "";
> +	}
> +}
> +
> +static __init u32 hmat_normalize(u16 entry, u64 base, u8 type)
> +{
> +	u32 value;
> +
> +	/*
> +	 * Check for invalid and overflow values
> +	 */
> +	if (entry == 0xffff || !entry)
> +		return 0;
> +	else if (base > (UINT_MAX / (entry)))

In this particular case, the issue is not that the value provided is impossible
but rather that the kernel is currently using too small a type to hold it.
If I've understood that right, perhaps a warning here would make sense?

Also, for consistency, U32_MAX.


> +		return 0;
> +
> +	/*
> +	 * Divide by the base unit for version 1, convert latency from
> +	 * picosenonds to nanoseconds if revision 2.
> +	 */
> +	value = entry * base;
> +	if (hmat_revision == 1) {
> +		if (value < 10)
> +			return 0;
> +		value = DIV_ROUND_UP(value, 10);
> +	} else if (hmat_revision == 2) {
> +		switch (type) {
> +		case ACPI_HMAT_ACCESS_LATENCY:
> +		case ACPI_HMAT_READ_LATENCY:
> +		case ACPI_HMAT_WRITE_LATENCY:
> +			value = DIV_ROUND_UP(value, 1000);

In this case our use of a u32 is resulting in a value that is clamped
way below the full u32 range.  Perhaps locally do the computation at
higher precision then clamp down at the end?

> +			break;
> +		default:
> +			break;
> +		}
> +	}
> +	return value;
> +}
> +
> +static __init int hmat_parse_locality(union acpi_subtable_headers *header,
> +				      const unsigned long end)
> +{
> +	struct acpi_hmat_locality *hmat_loc = (void *)header;
> +	unsigned int init, targ, total_size, ipds, tpds;
> +	u32 *inits, *targs, value;
> +	u16 *entries;
> +	u8 type;
> +
> +	if (hmat_loc->header.length < sizeof(*hmat_loc)) {
> +		pr_notice("HMAT: Unexpected locality header length: %d\n",
> +			 hmat_loc->header.length);
> +		return -EINVAL;
> +	}
> +
> +	type = hmat_loc->data_type;
> +	ipds = hmat_loc->number_of_initiator_Pds;
> +	tpds = hmat_loc->number_of_target_Pds;
> +	total_size = sizeof(*hmat_loc) + sizeof(*entries) * ipds * tpds +
> +		     sizeof(*inits) * ipds + sizeof(*targs) * tpds;
> +	if (hmat_loc->header.length < total_size) {

Perhaps overly paranoid, but could we make that a != to catch potential
broken tables?

> +		pr_notice("HMAT: Unexpected locality header length:%d, minimum required:%d\n",
> +			 hmat_loc->header.length, total_size);
> +		return -EINVAL;
> +	}
> +
> +	pr_info("HMAT: Locality: Flags:%02x Type:%s Initiator Domains:%d Target Domains:%d Base:%lld\n",
> +		hmat_loc->flags, hmat_data_type(type), ipds, tpds,
> +		hmat_loc->entry_base_unit);
> +
> +	inits = (u32 *)(hmat_loc + 1);
> +	targs = inits + ipds;
> +	entries = (u16 *)(targs + tpds);
> +	for (init = 0; init < ipds; init++) {
> +		for (targ = 0; targ < tpds; targ++) {
> +			value = hmat_normalize(entries[init * tpds + targ],
> +					       hmat_loc->entry_base_unit,
> +					       type);
> +			pr_info("  Initiator-Target[%d-%d]:%d%s\n",
> +				inits[init], targs[targ], value,
> +				hmat_data_type_suffix(type));
> +		}
> +	}
> +
> +	return 0;
> +}
> +
> +static __init int hmat_parse_cache(union acpi_subtable_headers *header,
> +				   const unsigned long end)
> +{
> +	struct acpi_hmat_cache *cache = (void *)header;
> +	u32 attrs;
> +
> +	if (cache->header.length < sizeof(*cache)) {
> +		pr_notice("HMAT: Unexpected cache header length: %d\n",
> +			 cache->header.length);
> +		return -EINVAL;
> +	}
> +
> +	attrs = cache->cache_attributes;
> +	pr_info("HMAT: Cache: Domain:%d Size:%llu Attrs:%08x SMBIOS Handles:%d\n",
> +		cache->memory_PD, cache->cache_size, attrs,
> +		cache->number_of_SMBIOShandles);
> +
> +	return 0;
> +}
> +
> +static int __init hmat_parse_address_range(union acpi_subtable_headers *header,
> +					   const unsigned long end)
> +{
> +	struct acpi_hmat_proximity_domain *p = (void *)header;
> +	struct memory_target *target = NULL;
> +
> +	if (p->header.length != sizeof(*p)) {
> +		pr_notice("HMAT: Unexpected address range header length: %d\n",
> +			 p->header.length);
> +		return -EINVAL;
> +	}
> +
> +	if (hmat_revision == 1)
> +		pr_info("HMAT: Memory (%#llx length %#llx) Flags:%04x Processor Domain:%d Memory Domain:%d\n",
> +			p->reserved3, p->reserved4, p->flags, p->processor_PD,
> +			p->memory_PD);
> +	else
> +		pr_info("HMAT: Memory Flags:%04x Processor Domain:%d Memory Domain:%d\n",
> +			p->flags, p->processor_PD, p->memory_PD);
> +
> +	return 0;
> +}
> +
> +static int __init hmat_parse_subtable(union acpi_subtable_headers *header,
> +				      const unsigned long end)
> +{
> +	struct acpi_hmat_structure *hdr = (void *)header;
> +
> +	if (!hdr)
> +		return -EINVAL;
> +
> +	switch (hdr->type) {
> +	case ACPI_HMAT_TYPE_ADDRESS_RANGE:
> +		return hmat_parse_address_range(header, end);
> +	case ACPI_HMAT_TYPE_LOCALITY:
> +		return hmat_parse_locality(header, end);
> +	case ACPI_HMAT_TYPE_CACHE:
> +		return hmat_parse_cache(header, end);
> +	default:
> +		return -EINVAL;
> +	}
> +}
> +
> +static __init int hmat_init(void)
> +{
> +	struct acpi_table_header *tbl;
> +	enum acpi_hmat_type i;
> +	acpi_status status;
> +
> +	if (srat_disabled())
> +		return 0;
> +
> +	status = acpi_get_table(ACPI_SIG_HMAT, 0, &tbl);
> +	if (ACPI_FAILURE(status))
> +		return 0;
> +
> +	hmat_revision = tbl->revision;
> +	switch (hmat_revision) {
> +	case 1:
> +	case 2:
> +		break;
> +	default:
> +		pr_notice("Ignoring HMAT: Unknown revision:%d\n", hmat_revision);
> +		goto out_put;
> +	}
> +
> +	for (i = ACPI_HMAT_TYPE_ADDRESS_RANGE; i < ACPI_HMAT_TYPE_RESERVED; i++) {
> +		if (acpi_table_parse_entries(ACPI_SIG_HMAT,
> +					     sizeof(struct acpi_table_hmat), i,
> +					     hmat_parse_subtable, 0) < 0) {
> +			pr_notice("Ignoring HMAT: Invalid table");
> +			goto out_put;
> +		}
> +	}
> +out_put:
> +	acpi_put_table(tbl);
> +	return 0;
> +}
> +subsys_initcall(hmat_init);


