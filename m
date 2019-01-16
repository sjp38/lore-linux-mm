Return-Path: <SRS0=bSwl=PY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED4DCC43387
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 21:51:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9213B20652
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 21:51:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="nhYp9JtD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9213B20652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 30D9F8E0004; Wed, 16 Jan 2019 16:51:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 296748E0002; Wed, 16 Jan 2019 16:51:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1363D8E0004; Wed, 16 Jan 2019 16:51:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id D6AEE8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 16:51:14 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id d93so4083965otb.12
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 13:51:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Kw7JbI3Xgqn93oQvnbMD0ZqFezzNCRUL2XbO7gXNx6E=;
        b=My46Zb3ZAaMUscDKXTHHB6jXcYQSsXdDfe8TtIVTLWuJT2HgQ/mniIcwFgXPRSAHKU
         +Kh15tin+b2GVUrJBKICNMjQPm0L6ZeVOv2TXNqQHtRON7u5YSWKFiegpL3CbZz18I3g
         5v3SyUHp3FD4kvRotWIKBC4pRsfL23jPK/S14lE5aJXyS823rcMy9bfUX6IHhGdoECKo
         waHkFRxB8oh95CMeU1IQBWqG4YY5hh2+TCtR7vy/UUhH+D6EhNeH8Fhx1QvMqbjX3oot
         3hZ+hAMljPobEhugWZnrBveJS/qqpY3LEwrjti2qiSB9ck9N1D5WkDHc0F/+SRjIkYaY
         na6g==
X-Gm-Message-State: AJcUuke8wA9/9/iE6tHCjAXQBDcwvjNgstV8u8RidHb3yItYUMBv4UQW
	oKx0YAdQGi5IkKnAJUR0m/LoYF0b4flBfO9n5v9xLSaAebkQ2/VoSUTKV1ue36vg/4MpyZSLivl
	J2Iwug76h1eBJQcp0lnhi6AMW/KJukgshkz0a7ySyLwPio6mD8XEtbSYssi8VWULqdgorY/+Ie1
	oxvTbR/B5pqw5yTugg/9aPb2u32+2hQHqNLWzktj+QP7sWku8M36J5UpEND9xJ/2eZiR3OuXEUc
	etwyId3Qf2dRRf/MtCtHF3V6Z86pA/noXJkXiQ1RoUrCuNbERh/aonrjLl/m5qdXXH8teeukavT
	1kjU2HV/pnEZgsgBLEe7PdEXtDGNJ3VEUxL2yvausXrYYETbwmsiF6to4E/LUcoqPciYcgU0zmU
	N
X-Received: by 2002:aca:b2c4:: with SMTP id b187mr4057111oif.245.1547675474445;
        Wed, 16 Jan 2019 13:51:14 -0800 (PST)
X-Received: by 2002:aca:b2c4:: with SMTP id b187mr4057086oif.245.1547675473518;
        Wed, 16 Jan 2019 13:51:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547675473; cv=none;
        d=google.com; s=arc-20160816;
        b=OmDT5T2JE2LTPm4ZMrojX7urI7WVeX/QhTEj+kgykZduZz1YTTi6W9vhbKVA9EDJlk
         j5N2UomK2UY455nF17UVpngHmioukSKXaY6wCEGg4ArH1fcMQnX54lfqWK0AViQSiFkX
         syu7h5xk1YFxFCkMqgr3qQtEu93OzCOBPm19GMPKVUJNtsUhr7RjMKK4N9r1/F/zze+m
         CpmvDNXT9iIiQSk1P8/HIF717rL2HS0HLBuO4WFixVjx1oNhEU3c5BkJlOltu/9qAsid
         oamTVkIOcx2CX0U6kHm+0OyhOFUgbJOpJXNfgvthJ+FS5auR9hIcQ0SHQtiZDRN/WYNZ
         r96A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Kw7JbI3Xgqn93oQvnbMD0ZqFezzNCRUL2XbO7gXNx6E=;
        b=mIUC2aP+NoS8FeF/6+FWL2uwSgYC0ehQAT+3bX2GebCsDBQd9t8dn/9EhHxJEPBrpD
         BXu4YgHIgQeCrIu6UYvnbo3OL+URy/jrcI94G/nqQLj+Qz4J9Us5ORg9UTsw8Z6V5Mzu
         8yvXfwFtbOAUQhN/fWMWwwaYziB8L1DiWpzvL9iSCxBjX6a9BKYKD1NpT8mtB+5U4nAg
         s9fVM9DrPVg+cIpdW5n3hWoBBlL/cxBkb7AKNPfoFuojSeujP+YzfVce4LtqcuCv6tML
         7o2ogX1b+nY5h103alpkAalwhc/2acjXXAAZW7EXv+qIoiQarrYQuYjgfoBVJB5Qfhfo
         hcKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=nhYp9JtD;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g133sor1445051oia.162.2019.01.16.13.51.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 16 Jan 2019 13:51:13 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=nhYp9JtD;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Kw7JbI3Xgqn93oQvnbMD0ZqFezzNCRUL2XbO7gXNx6E=;
        b=nhYp9JtDG3YXeIyNXilzl9w2KaNMOr5iflUo+0GmeC4eoPGL425FI2S1mwaRIoXE/o
         xu/ub/UaT9/+lv6wqPjqwXtliBGK/uIZhE26w6p579UaOavFaJGibG5gSL0NBkMBaF+8
         Pi242OViyTYMmhUtqnqHz44/2rbQgepeWvatIiHCqyU5FKSSun0dj2rsNZ1vgwyLgmbL
         eYi7cmNpCqPIpGH7X9mqW+6App1YEi9SLgBzYFevK+0uWLDO3dudoPfdVR5Jn31MfSVU
         9sOy8eXSVVgOcXyGg5Iz1kuOiM5CUTfc/SIHUgcEm11gwmK/O5q+EfgFHhUiAhQiZEov
         XvAA==
X-Google-Smtp-Source: ALg8bN5yA0Zw7915fk1fTg22AvNzuaZPOxGYGmrGVLMenMtlvqDnBz4+ZHHiXjzb6FRM/jgj73g2ZJWcR9urTTgcaEE=
X-Received: by 2002:aca:d78b:: with SMTP id o133mr1302044oig.232.1547674272632;
 Wed, 16 Jan 2019 13:31:12 -0800 (PST)
MIME-Version: 1.0
References: <20190116181859.D1504459@viggo.jf.intel.com> <20190116181905.12E102B4@viggo.jf.intel.com>
In-Reply-To: <20190116181905.12E102B4@viggo.jf.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 16 Jan 2019 13:31:01 -0800
Message-ID:
 <CAPcyv4j4_Wr2O9CBHNNVgB8ebOGu=-w5paqbBwVEn5dyXHLyKA@mail.gmail.com>
Subject: Re: [PATCH 4/4] dax: "Hotplug" persistent memory for use like normal RAM
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Dave Hansen <dave@sr71.net>, Dave Jiang <dave.jiang@intel.com>, 
	Ross Zwisler <zwisler@kernel.org>, Vishal L Verma <vishal.l.verma@intel.com>, 
	Tom Lendacky <thomas.lendacky@amd.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	"Huang, Ying" <ying.huang@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, 
	Borislav Petkov <bp@suse.de>, Bjorn Helgaas <bhelgaas@google.com>, 
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Takashi Iwai <tiwai@suse.de>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190116213101.SmcAN29J1-cjYoAM_-mEVpxSuddk3BTwPlmIzxs0Zrw@z>

On Wed, Jan 16, 2019 at 10:25 AM Dave Hansen
<dave.hansen@linux.intel.com> wrote:
>
>
> From: Dave Hansen <dave.hansen@linux.intel.com>
>
> Currently, a persistent memory region is "owned" by a device driver,
> either the "Direct DAX" or "Filesystem DAX" drivers.  These drivers
> allow applications to explicitly use persistent memory, generally
> by being modified to use special, new libraries.
>
> However, this limits persistent memory use to applications which
> *have* been modified.  To make it more broadly usable, this driver
> "hotplugs" memory into the kernel, to be managed ad used just like
> normal RAM would be.
>
> To make this work, management software must remove the device from
> being controlled by the "Device DAX" infrastructure:
>
>         echo -n dax0.0 > /sys/bus/dax/drivers/device_dax/remove_id
>         echo -n dax0.0 > /sys/bus/dax/drivers/device_dax/unbind
>
> and then bind it to this new driver:
>
>         echo -n dax0.0 > /sys/bus/dax/drivers/kmem/new_id
>         echo -n dax0.0 > /sys/bus/dax/drivers/kmem/bind
>
> After this, there will be a number of new memory sections visible
> in sysfs that can be onlined, or that may get onlined by existing
> udev-initiated memory hotplug rules.
>
> Note: this inherits any existing NUMA information for the newly-
> added memory from the persistent memory device that came from the
> firmware.  On Intel platforms, the firmware has guarantees that
> require each socket's persistent memory to be in a separate
> memory-only NUMA node.  That means that this patch is not expected
> to create NUMA nodes, but will simply hotplug memory into existing
> nodes.
>
> There is currently some metadata at the beginning of pmem regions.
> The section-size memory hotplug restrictions, plus this small
> reserved area can cause the "loss" of a section or two of capacity.
> This should be fixable in follow-on patches.  But, as a first step,
> losing 256MB of memory (worst case) out of hundreds of gigabytes
> is a good tradeoff vs. the required code to fix this up precisely.
>
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Dave Jiang <dave.jiang@intel.com>
> Cc: Ross Zwisler <zwisler@kernel.org>
> Cc: Vishal Verma <vishal.l.verma@intel.com>
> Cc: Tom Lendacky <thomas.lendacky@amd.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: linux-nvdimm@lists.01.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: Huang Ying <ying.huang@intel.com>
> Cc: Fengguang Wu <fengguang.wu@intel.com>
> Cc: Borislav Petkov <bp@suse.de>
> Cc: Bjorn Helgaas <bhelgaas@google.com>
> Cc: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
> Cc: Takashi Iwai <tiwai@suse.de>
> ---
>
>  b/drivers/dax/Kconfig  |    5 ++
>  b/drivers/dax/Makefile |    1
>  b/drivers/dax/kmem.c   |   93 +++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 99 insertions(+)
>
> diff -puN drivers/dax/Kconfig~dax-kmem-try-4 drivers/dax/Kconfig
> --- a/drivers/dax/Kconfig~dax-kmem-try-4        2019-01-08 09:54:44.051694874 -0800
> +++ b/drivers/dax/Kconfig       2019-01-08 09:54:44.056694874 -0800
> @@ -32,6 +32,11 @@ config DEV_DAX_PMEM
>
>           Say M if unsure
>
> +config DEV_DAX_KMEM
> +       def_bool y
> +       depends on DEV_DAX_PMEM   # Needs DEV_DAX_PMEM infrastructure
> +       depends on MEMORY_HOTPLUG # for add_memory() and friends
> +

I think this should be:

config DEV_DAX_KMEM
       tristate "<kmem title>"
       depends on DEV_DAX
       default DEV_DAX
       depends on MEMORY_HOTPLUG # for add_memory() and friends
       help
           <kmem description>

...because the DEV_DAX_KMEM implementation with the device-DAX reworks
is independent of pmem. It just so happens that pmem is the only
source for device-DAX instances, but that need not always be the case
and kmem is device-DAX origin generic.

>  config DEV_DAX_PMEM_COMPAT
>         tristate "PMEM DAX: support the deprecated /sys/class/dax interface"
>         depends on DEV_DAX_PMEM
> diff -puN /dev/null drivers/dax/kmem.c
> --- /dev/null   2018-12-03 08:41:47.355756491 -0800
> +++ b/drivers/dax/kmem.c        2019-01-08 09:54:44.056694874 -0800
> @@ -0,0 +1,93 @@
> +// SPDX-License-Identifier: GPL-2.0
> +/* Copyright(c) 2016-2018 Intel Corporation. All rights reserved. */
> +#include <linux/memremap.h>
> +#include <linux/pagemap.h>
> +#include <linux/memory.h>
> +#include <linux/module.h>
> +#include <linux/device.h>
> +#include <linux/pfn_t.h>
> +#include <linux/slab.h>
> +#include <linux/dax.h>
> +#include <linux/fs.h>
> +#include <linux/mm.h>
> +#include <linux/mman.h>
> +#include "dax-private.h"
> +#include "bus.h"
> +
> +int dev_dax_kmem_probe(struct device *dev)
> +{
> +       struct dev_dax *dev_dax = to_dev_dax(dev);
> +       struct resource *res = &dev_dax->region->res;
> +       resource_size_t kmem_start;
> +       resource_size_t kmem_size;
> +       struct resource *new_res;
> +       int numa_node;
> +       int rc;
> +
> +       /* Hotplug starting at the beginning of the next block: */
> +       kmem_start = ALIGN(res->start, memory_block_size_bytes());
> +
> +       kmem_size = resource_size(res);
> +       /* Adjust the size down to compensate for moving up kmem_start: */
> +        kmem_size -= kmem_start - res->start;
> +       /* Align the size down to cover only complete blocks: */
> +       kmem_size &= ~(memory_block_size_bytes() - 1);
> +
> +       new_res = devm_request_mem_region(dev, kmem_start, kmem_size,
> +                                         dev_name(dev));
> +
> +       if (!new_res) {
> +               printk("could not reserve region %016llx -> %016llx\n",
> +                               kmem_start, kmem_start+kmem_size);

dev_err() please.

> +               return -EBUSY;
> +       }
> +
> +       /*
> +        * Set flags appropriate for System RAM.  Leave ..._BUSY clear
> +        * so that add_memory() can add a child resource.
> +        */
> +       new_res->flags = IORESOURCE_SYSTEM_RAM;
> +       new_res->name = dev_name(dev);
> +
> +       numa_node = dev_dax->target_node;
> +       if (numa_node < 0) {
> +               pr_warn_once("bad numa_node: %d, forcing to 0\n", numa_node);

I think this should be dev_info(dev, "no numa_node, defaulting to
0\n"), or dev_dbg():

1/ so we can backtrack which device is missing numa information
2/ NUMA_NO_NODE may be a common occurrence so it's not really a "warn"
level concern afaics.
3/ no real need for _once I don't see this as a log spam risk.

> +               numa_node = 0;
> +       }
> +
> +       rc = add_memory(numa_node, new_res->start, resource_size(new_res));
> +       if (rc)
> +               return rc;
> +
> +       return 0;
> +}
> +EXPORT_SYMBOL_GPL(dev_dax_kmem_probe);

No need to export this afaics.

> +
> +static int dev_dax_kmem_remove(struct device *dev)
> +{
> +       /* Assume that hot-remove will fail for now */
> +       return -EBUSY;
> +}
> +
> +static struct dax_device_driver device_dax_kmem_driver = {
> +       .drv = {
> +               .probe = dev_dax_kmem_probe,
> +               .remove = dev_dax_kmem_remove,
> +       },
> +};
> +
> +static int __init dax_kmem_init(void)
> +{
> +       return dax_driver_register(&device_dax_kmem_driver);
> +}
> +
> +static void __exit dax_kmem_exit(void)
> +{
> +       dax_driver_unregister(&device_dax_kmem_driver);
> +}
> +
> +MODULE_AUTHOR("Intel Corporation");
> +MODULE_LICENSE("GPL v2");
> +module_init(dax_kmem_init);
> +module_exit(dax_kmem_exit);
> +MODULE_ALIAS_DAX_DEVICE(0);
> diff -puN drivers/dax/Makefile~dax-kmem-try-4 drivers/dax/Makefile
> --- a/drivers/dax/Makefile~dax-kmem-try-4       2019-01-08 09:54:44.053694874 -0800
> +++ b/drivers/dax/Makefile      2019-01-08 09:54:44.056694874 -0800
> @@ -1,6 +1,7 @@
>  # SPDX-License-Identifier: GPL-2.0
>  obj-$(CONFIG_DAX) += dax.o
>  obj-$(CONFIG_DEV_DAX) += device_dax.o
> +obj-$(CONFIG_DEV_DAX_KMEM) += kmem.o
>
>  dax-y := super.o
>  dax-y += bus.o
> _

