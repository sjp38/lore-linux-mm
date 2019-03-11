Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0316C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 11:21:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2CE212075C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 11:21:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2CE212075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 951198E0017; Mon, 11 Mar 2019 07:21:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8DC4B8E0002; Mon, 11 Mar 2019 07:21:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7546F8E0017; Mon, 11 Mar 2019 07:21:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 37E458E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 07:21:03 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id 66so2578966otl.23
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 04:21:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=hwsD6TSOaMYK+Rz4kgTedg5JA74j1AUQB8Zat4Q/U5g=;
        b=gaezYCLvXsukwmypukoKSnxddYtQ57USzB/29JgYqfQc0lTw0xgIFGe2mQte003B86
         ty2NycJMT8Y1LLPyB2Kgnp50MTAibEL9lz8spszqGty1v7wmpUeIQy8Fgq8847Rtu1G7
         TCFlrnWJWMJIEhskORmVPfFNPX68k3YduJQDnqrW04bs4O5/6C8HXrLRkpvZ2rTmKEON
         lnYdJQ7zNbbmsrHCAQWi5xf92AnwA0OmD2goOQ/W66Hih7Em4uU09hVtk3FJX8HNdrER
         /GRhm8bxvnufCNBd8A8iSUQbz8oJyrMs2fvKn+i5+UoMFSobCy/MmUx52CD2/WV+0m1j
         EW7A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: APjAAAUhv0W16AoPJJPLiZWZb/9YoevTnQ2J+iMQ7o8yGQlGIPHSw4JS
	GXuaLaGpF2nuUYh1nbFa3ot9xxlsw42V76TRxdXmL0/PreKW/M+qEzHEa9lIPjjMHd6oF3jfwsm
	juc+cV9xjNlkzcbPrilxxwumwo9lga01PVatoAj3/l/isBLusCFr4aisZXKlEx0Vmgw==
X-Received: by 2002:aca:dc8b:: with SMTP id t133mr17115756oig.25.1552303262797;
        Mon, 11 Mar 2019 04:21:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzjYzSAXOA+Sa6MJuPlQixshwv6RwXmPQVDoBK1P3X6z8rVOHQ+sJv3NGMeJGSt9Dp+nHDA
X-Received: by 2002:aca:dc8b:: with SMTP id t133mr17115697oig.25.1552303261190;
        Mon, 11 Mar 2019 04:21:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552303261; cv=none;
        d=google.com; s=arc-20160816;
        b=c4oIrbSuzkw8OopfV38vEilGscPo7mkQN9snRnfq2uKji74a2STJEmnB3A3tRNn7Wx
         iFowuCWdsaNufUKb6jVC2GSBU33HoEAdBQcSKjFbTJ9w/4Bz43WPKhPcDurkVv7im2FT
         emgA7ptjeESNORL7S9meRUufTkdvUu1SatVVZtwh7cKiYCr/QOu01D84VigiKRh4fWTq
         EV8gyeRYWDcJX5I1GQ/ZhnELVkVlC9hDz8zrOC/WL5v4DbQVHEsInXVH5pzGAeJDcnIt
         cKAHa0LVdtudZ9rlClg684Ho9NuDGfib/GAprOwXXZcTimIbP+7K2lJAnjKepfR3935w
         PHIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=hwsD6TSOaMYK+Rz4kgTedg5JA74j1AUQB8Zat4Q/U5g=;
        b=pEt23/ebxLuCPE/0K7izrgUK8XXfF7JTXB9Wc4s+T6YzMJrUkscvUQ2Rl1rvFy+6cx
         fUxqt+dUg5A2ZLbenXLF1bn+NEHhDA5orYirHGYczBW8QN+G+BgNwwS1tLtW0tZAYxi7
         mdgIziRtcbVblye/s1Nt3y1WlXD/mZzdwsUTmBfpAOTF1MnQPQXpxlYfeEhXnJLS360/
         xYmlvoj7XtD1vKV3Wz08keAFdanbFbJLi0NMZKrXtcxeZhPELkEhFPePM+H8n2iE00N4
         m2jsxURbP8Jx/PB0VGdR3VBc/A+AdTZE690cSpoWPOCeHeaeL97O+TmEfmCcUf2J/Pmx
         P0gQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id l66si2212270oib.62.2019.03.11.04.21.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 04:21:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS409-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 3CB268F25783643E8322;
	Mon, 11 Mar 2019 19:20:57 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS409-HUB.china.huawei.com
 (10.3.19.209) with Microsoft SMTP Server id 14.3.408.0; Mon, 11 Mar 2019
 19:20:51 +0800
Date: Mon, 11 Mar 2019 11:20:41 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Keith Busch <keith.busch@intel.com>
CC: <linux-kernel@vger.kernel.org>, <linux-acpi@vger.kernel.org>,
	<linux-mm@kvack.org>, <linux-api@vger.kernel.org>, Greg Kroah-Hartman
	<gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, "Dave
 Hansen" <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCHv7 07/10] acpi/hmat: Register processor domain to its
 memory
Message-ID: <20190311112041.000015ba@huawei.com>
In-Reply-To: <20190227225038.20438-8-keith.busch@intel.com>
References: <20190227225038.20438-1-keith.busch@intel.com>
	<20190227225038.20438-8-keith.busch@intel.com>
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

On Wed, 27 Feb 2019 15:50:35 -0700
Keith Busch <keith.busch@intel.com> wrote:

> If the HMAT Subsystem Address Range provides a valid processor proximity
> domain for a memory domain, or a processor domain matches the performance
> access of the valid processor proximity domain, register the memory
> target with that initiator so this relationship will be visible under
> the node's sysfs directory.
> 
> Since HMAT requires valid address ranges have an equivalent SRAT entry,
> verify each memory target satisfies this requirement.
> 
> Signed-off-by: Keith Busch <keith.busch@intel.com>
Hi Keith,

I have that test case with a single remote memory only node and it is ending
up with no associated initiators.

I made a minor modification inline and it works as expected.

With that change

Reviewed-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>

Jonathan
> ---
>  drivers/acpi/hmat/Kconfig |   3 +-
>  drivers/acpi/hmat/hmat.c  | 395 +++++++++++++++++++++++++++++++++++++++++++++-
>  2 files changed, 396 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/acpi/hmat/Kconfig b/drivers/acpi/hmat/Kconfig
> index 2f7111b7af62..13cddd612a52 100644
> --- a/drivers/acpi/hmat/Kconfig
> +++ b/drivers/acpi/hmat/Kconfig
> @@ -4,4 +4,5 @@ config ACPI_HMAT
>  	depends on ACPI_NUMA
>  	help
>  	 If set, this option has the kernel parse and report the
> -	 platform's ACPI HMAT (Heterogeneous Memory Attributes Table).
> +	 platform's ACPI HMAT (Heterogeneous Memory Attributes Table),
> +	 and register memory initiators with their targets.
> diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
> index 99f711420f6d..bb6a11653729 100644
> --- a/drivers/acpi/hmat/hmat.c
> +++ b/drivers/acpi/hmat/hmat.c
> @@ -13,11 +13,105 @@
>  #include <linux/device.h>
>  #include <linux/init.h>
>  #include <linux/list.h>
> +#include <linux/list_sort.h>
>  #include <linux/node.h>
>  #include <linux/sysfs.h>
>  
>  static __initdata u8 hmat_revision;
>  
> +static __initdata LIST_HEAD(targets);
> +static __initdata LIST_HEAD(initiators);
> +static __initdata LIST_HEAD(localities);
> +
> +/*
> + * The defined enum order is used to prioritize attributes to break ties when
> + * selecting the best performing node.
> + */
> +enum locality_types {
> +	WRITE_LATENCY,
> +	READ_LATENCY,
> +	WRITE_BANDWIDTH,
> +	READ_BANDWIDTH,
> +};
> +
> +static struct memory_locality *localities_types[4];
> +
> +struct memory_target {
> +	struct list_head node;
> +	unsigned int memory_pxm;
> +	unsigned int processor_pxm;
> +	struct node_hmem_attrs hmem_attrs;
> +};
> +
> +struct memory_initiator {
> +	struct list_head node;
> +	unsigned int processor_pxm;
> +};
> +
> +struct memory_locality {
> +	struct list_head node;
> +	struct acpi_hmat_locality *hmat_loc;
> +};
> +
> +static __init struct memory_initiator *find_mem_initiator(unsigned int cpu_pxm)
> +{
> +	struct memory_initiator *intitator;
> +
> +	list_for_each_entry(intitator, &initiators, node)
> +		if (intitator->processor_pxm == cpu_pxm)
> +			return intitator;
> +	return NULL;
> +}
> +
> +static __init struct memory_target *find_mem_target(unsigned int mem_pxm)
> +{
> +	struct memory_target *target;
> +
> +	list_for_each_entry(target, &targets, node)
> +		if (target->memory_pxm == mem_pxm)
> +			return target;
> +	return NULL;
> +}
> +
> +static __init void alloc_memory_initiator(unsigned int cpu_pxm)
> +{
> +	struct memory_initiator *intitator;
> +
> +	if (pxm_to_node(cpu_pxm) == NUMA_NO_NODE)
> +		return;
> +
> +	intitator = find_mem_initiator(cpu_pxm);
> +	if (intitator)
> +		return;
> +
> +	intitator = kzalloc(sizeof(*intitator), GFP_KERNEL);
> +	if (!intitator)
> +		return;
> +
> +	intitator->processor_pxm = cpu_pxm;
> +	list_add_tail(&intitator->node, &initiators);
> +}
> +
> +static __init void alloc_memory_target(unsigned int mem_pxm)
> +{
> +	struct memory_target *target;
> +
> +	if (pxm_to_node(mem_pxm) == NUMA_NO_NODE)
> +		return;
> +
> +	target = find_mem_target(mem_pxm);
> +	if (target)
> +		return;
> +
> +	target = kzalloc(sizeof(*target), GFP_KERNEL);
> +	if (!target)
> +		return;
> +
> +	target->memory_pxm = mem_pxm;
> +	target->processor_pxm = PXM_INVAL;
> +	list_add_tail(&target->node, &targets);
> +}
> +
>  static __init const char *hmat_data_type(u8 type)
>  {
>  	switch (type) {
> @@ -89,14 +183,83 @@ static __init u32 hmat_normalize(u16 entry, u64 base, u8 type)
>  	return value;
>  }
>  
> +static __init void hmat_update_target_access(struct memory_target *target,
> +					     u8 type, u32 value)
> +{
> +	switch (type) {
> +	case ACPI_HMAT_ACCESS_LATENCY:
> +		target->hmem_attrs.read_latency = value;
> +		target->hmem_attrs.write_latency = value;
> +		break;
> +	case ACPI_HMAT_READ_LATENCY:
> +		target->hmem_attrs.read_latency = value;
> +		break;
> +	case ACPI_HMAT_WRITE_LATENCY:
> +		target->hmem_attrs.write_latency = value;
> +		break;
> +	case ACPI_HMAT_ACCESS_BANDWIDTH:
> +		target->hmem_attrs.read_bandwidth = value;
> +		target->hmem_attrs.write_bandwidth = value;
> +		break;
> +	case ACPI_HMAT_READ_BANDWIDTH:
> +		target->hmem_attrs.read_bandwidth = value;
> +		break;
> +	case ACPI_HMAT_WRITE_BANDWIDTH:
> +		target->hmem_attrs.write_bandwidth = value;
> +		break;
> +	default:
> +		break;
> +	}
> +}
> +
> +static __init void hmat_add_locality(struct acpi_hmat_locality *hmat_loc)
> +{
> +	struct memory_locality *loc;
> +
> +	loc = kzalloc(sizeof(*loc), GFP_KERNEL);
> +	if (!loc) {
> +		pr_notice_once("Failed to allocate HMAT locality\n");
> +		return;
> +	}
> +
> +	loc->hmat_loc = hmat_loc;
> +	list_add_tail(&loc->node, &localities);
> +
> +	switch (hmat_loc->data_type) {
> +	case ACPI_HMAT_ACCESS_LATENCY:
> +		localities_types[READ_LATENCY] = loc;
> +		localities_types[WRITE_LATENCY] = loc;
> +		break;
> +	case ACPI_HMAT_READ_LATENCY:
> +		localities_types[READ_LATENCY] = loc;
> +		break;
> +	case ACPI_HMAT_WRITE_LATENCY:
> +		localities_types[WRITE_LATENCY] = loc;
> +		break;
> +	case ACPI_HMAT_ACCESS_BANDWIDTH:
> +		localities_types[READ_BANDWIDTH] = loc;
> +		localities_types[WRITE_BANDWIDTH] = loc;
> +		break;
> +	case ACPI_HMAT_READ_BANDWIDTH:
> +		localities_types[READ_BANDWIDTH] = loc;
> +		break;
> +	case ACPI_HMAT_WRITE_BANDWIDTH:
> +		localities_types[WRITE_BANDWIDTH] = loc;
> +		break;
> +	default:
> +		break;
> +	}
> +}
> +
>  static __init int hmat_parse_locality(union acpi_subtable_headers *header,
>  				      const unsigned long end)
>  {
>  	struct acpi_hmat_locality *hmat_loc = (void *)header;
> +	struct memory_target *target;
>  	unsigned int init, targ, total_size, ipds, tpds;
>  	u32 *inits, *targs, value;
>  	u16 *entries;
> -	u8 type;
> +	u8 type, mem_hier;
>  
>  	if (hmat_loc->header.length < sizeof(*hmat_loc)) {
>  		pr_notice("HMAT: Unexpected locality header length: %d\n",
> @@ -105,6 +268,7 @@ static __init int hmat_parse_locality(union acpi_subtable_headers *header,
>  	}
>  
>  	type = hmat_loc->data_type;
> +	mem_hier = hmat_loc->flags & ACPI_HMAT_MEMORY_HIERARCHY;
>  	ipds = hmat_loc->number_of_initiator_Pds;
>  	tpds = hmat_loc->number_of_target_Pds;
>  	total_size = sizeof(*hmat_loc) + sizeof(*entries) * ipds * tpds +
> @@ -123,6 +287,7 @@ static __init int hmat_parse_locality(union acpi_subtable_headers *header,
>  	targs = inits + ipds;
>  	entries = (u16 *)(targs + tpds);
>  	for (init = 0; init < ipds; init++) {
> +		alloc_memory_initiator(inits[init]);
>  		for (targ = 0; targ < tpds; targ++) {
>  			value = hmat_normalize(entries[init * tpds + targ],
>  					       hmat_loc->entry_base_unit,
> @@ -130,9 +295,18 @@ static __init int hmat_parse_locality(union acpi_subtable_headers *header,
>  			pr_info("  Initiator-Target[%d-%d]:%d%s\n",
>  				inits[init], targs[targ], value,
>  				hmat_data_type_suffix(type));
> +
> +			if (mem_hier == ACPI_HMAT_MEMORY) {
> +				target = find_mem_target(targs[targ]);
> +				if (target && target->processor_pxm == inits[init])
> +					hmat_update_target_access(target, type, value);
> +			}
>  		}
>  	}
>  
> +	if (mem_hier == ACPI_HMAT_MEMORY)
> +		hmat_add_locality(hmat_loc);
> +
>  	return 0;
>  }
>  
> @@ -176,6 +350,23 @@ static int __init hmat_parse_address_range(union acpi_subtable_headers *header,
>  		pr_info("HMAT: Memory Flags:%04x Processor Domain:%d Memory Domain:%d\n",
>  			p->flags, p->processor_PD, p->memory_PD);
>  
> +	if (p->flags & ACPI_HMAT_MEMORY_PD_VALID) {
> +		target = find_mem_target(p->memory_PD);
> +		if (!target) {
> +			pr_debug("HMAT: Memory Domain missing from SRAT\n");
> +			return -EINVAL;
> +		}
> +	}
> +	if (target && p->flags & ACPI_HMAT_PROCESSOR_PD_VALID) {
> +		int p_node = pxm_to_node(p->processor_PD);
> +
> +		if (p_node == NUMA_NO_NODE) {
> +			pr_debug("HMAT: Invalid Processor Domain\n");
> +			return -EINVAL;
> +		}
> +		target->processor_pxm = p_node;
> +	}
> +
>  	return 0;
>  }
>  
> @@ -199,6 +390,195 @@ static int __init hmat_parse_subtable(union acpi_subtable_headers *header,
>  	}
>  }
>  
> +static __init int srat_parse_mem_affinity(union acpi_subtable_headers *header,
> +					  const unsigned long end)
> +{
> +	struct acpi_srat_mem_affinity *ma = (void *)header;
> +
> +	if (!ma)
> +		return -EINVAL;
> +	if (!(ma->flags & ACPI_SRAT_MEM_ENABLED))
> +		return 0;
> +	alloc_memory_target(ma->proximity_domain);
> +	return 0;
> +}
> +
> +static __init u32 hmat_initiator_perf(struct memory_target *target,
> +			       struct memory_initiator *initiator,
> +			       struct acpi_hmat_locality *hmat_loc)
> +{
> +	unsigned int ipds, tpds, i, idx = 0, tdx = 0;
> +	u32 *inits, *targs;
> +	u16 *entries;
> +
> +	ipds = hmat_loc->number_of_initiator_Pds;
> +	tpds = hmat_loc->number_of_target_Pds;
> +	inits = (u32 *)(hmat_loc + 1);
> +	targs = inits + ipds;
> +	entries = (u16 *)(targs + tpds);
> +
> +	for (i = 0; i < ipds; i++) {
> +		if (inits[i] == initiator->processor_pxm) {
> +			idx = i;
> +			break;
> +		}
> +	}
> +
> +	if (i == ipds)
> +		return 0;
> +
> +	for (i = 0; i < tpds; i++) {
> +		if (targs[i] == target->memory_pxm) {
> +			tdx = i;
> +			break;
> +		}
> +	}
> +	if (i == tpds)
> +		return 0;
> +
> +	return hmat_normalize(entries[idx * tpds + tdx],
> +			      hmat_loc->entry_base_unit,
> +			      hmat_loc->data_type);
> +}
> +
> +static __init bool hmat_update_best(u8 type, u32 value, u32 *best)
> +{
> +	bool updated = false;
> +
> +	if (!value)
> +		return false;
> +
> +	switch (type) {
> +	case ACPI_HMAT_ACCESS_LATENCY:
> +	case ACPI_HMAT_READ_LATENCY:
> +	case ACPI_HMAT_WRITE_LATENCY:
> +		if (!*best || *best > value) {
> +			*best = value;
> +			updated = true;
> +		}
> +		break;
> +	case ACPI_HMAT_ACCESS_BANDWIDTH:
> +	case ACPI_HMAT_READ_BANDWIDTH:
> +	case ACPI_HMAT_WRITE_BANDWIDTH:
> +		if (!*best || *best < value) {
> +			*best = value;
> +			updated = true;
> +		}
> +		break;
> +	}
> +
> +	return updated;
> +}
> +
> +static int initiator_cmp(void *priv, struct list_head *a, struct list_head *b)
> +{
> +	struct memory_initiator *ia;
> +	struct memory_initiator *ib;
> +	unsigned long *p_nodes = priv;
> +
> +	ia = list_entry(a, struct memory_initiator, node);
> +	ib = list_entry(b, struct memory_initiator, node);
> +
> +	set_bit(ia->processor_pxm, p_nodes);
> +	set_bit(ib->processor_pxm, p_nodes);
> +
> +	return ia->processor_pxm - ib->processor_pxm;
> +}
> +
> +static __init void hmat_register_target_initiators(struct memory_target *target)
> +{
> +	static DECLARE_BITMAP(p_nodes, MAX_NUMNODES);
> +	struct memory_initiator *initiator;
> +	unsigned int mem_nid, cpu_nid;
> +	struct memory_locality *loc = NULL;
> +	u32 best = 0;
> +	int i;
> +
(upshot of the below is I removed this test :)
> +	if (target->processor_pxm == PXM_INVAL)
> +		return;

This doesn't look right.  We check first if it is invalid  and return....

> +
> +	mem_nid = pxm_to_node(target->memory_pxm);
> +
> +	/*
> +	 * If the Address Range Structure provides a local processor pxm, link
> +	 * only that one. Otherwise, find the best performance attribtes and
> +	 * register all initiators that match.
> +	 */
> +	if (target->processor_pxm != PXM_INVAL) {

Here we check the other path...

> +		cpu_nid = pxm_to_node(target->processor_pxm);
> +		register_memory_node_under_compute_node(mem_nid, cpu_nid, 0);
> +		return;
> +	}
> +

So we can't get here.


> +	if (list_empty(&localities))
> +		return;
> +
> +	/*
> +	 * We need the initiator list iteration sorted so we can use
> +	 * bitmap_clear for previously set initiators when we find a better
> +	 * memory accessor. We'll also use the sorting to prime the candidate
> +	 * nodes with known initiators.
> +	 */
> +	bitmap_zero(p_nodes, MAX_NUMNODES);
> +	list_sort(p_nodes, &initiators, initiator_cmp);
> +	for (i = WRITE_LATENCY; i <= READ_BANDWIDTH; i++) {
> +		loc = localities_types[i];
> +		if (!loc)
> +			continue;
> +
> +		best = 0;
> +		list_for_each_entry(initiator, &initiators, node) {
> +			u32 value;
> +
> +			if (!test_bit(initiator->processor_pxm, p_nodes))
> +				continue;
> +
> +			value = hmat_initiator_perf(target, initiator, loc->hmat_loc);
> +			if (hmat_update_best(loc->hmat_loc->data_type, value, &best))
> +				bitmap_clear(p_nodes, 0, initiator->processor_pxm);
> +			if (value != best)
> +				clear_bit(initiator->processor_pxm, p_nodes);
> +		}
> +		if (best)
> +			hmat_update_target_access(target, loc->hmat_loc->data_type, best);
> +	}
> +
> +	for_each_set_bit(i, p_nodes, MAX_NUMNODES) {
> +		cpu_nid = pxm_to_node(i);
> +		register_memory_node_under_compute_node(mem_nid, cpu_nid, 0);
> +	}
> +}
> +
> +static __init void hmat_register_targets(void)
> +{
> +	struct memory_target *target;
> +
> +	list_for_each_entry(target, &targets, node)
> +		hmat_register_target_initiators(target);
> +}
> +
> +static __init void hmat_free_structures(void)
> +{
> +	struct memory_target *target, *tnext;
> +	struct memory_locality *loc, *lnext;
> +	struct memory_initiator *intitator, *inext;
> +
> +	list_for_each_entry_safe(target, tnext, &targets, node) {
> +		list_del(&target->node);
> +		kfree(target);
> +	}
> +
> +	list_for_each_entry_safe(intitator, inext, &initiators, node) {
> +		list_del(&intitator->node);
> +		kfree(intitator);
> +	}
> +
> +	list_for_each_entry_safe(loc, lnext, &localities, node) {
> +		list_del(&loc->node);
> +		kfree(loc);
> +	}
> +}
> +
>  static __init int hmat_init(void)
>  {
>  	struct acpi_table_header *tbl;
> @@ -208,6 +588,17 @@ static __init int hmat_init(void)
>  	if (srat_disabled())
>  		return 0;
>  
> +	status = acpi_get_table(ACPI_SIG_SRAT, 0, &tbl);
> +	if (ACPI_FAILURE(status))
> +		return 0;
> +
> +	if (acpi_table_parse_entries(ACPI_SIG_SRAT,
> +				sizeof(struct acpi_table_srat),
> +				ACPI_SRAT_TYPE_MEMORY_AFFINITY,
> +				srat_parse_mem_affinity, 0) < 0)
> +		goto out_put;
> +	acpi_put_table(tbl);
> +
>  	status = acpi_get_table(ACPI_SIG_HMAT, 0, &tbl);
>  	if (ACPI_FAILURE(status))
>  		return 0;
> @@ -230,7 +621,9 @@ static __init int hmat_init(void)
>  			goto out_put;
>  		}
>  	}
> +	hmat_register_targets();
>  out_put:
> +	hmat_free_structures();
>  	acpi_put_table(tbl);
>  	return 0;
>  }


