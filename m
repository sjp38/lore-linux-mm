Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 373B2C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 21:27:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBE1020656
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 21:27:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="ByBpM4rz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBE1020656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 898B56B000A; Tue,  7 May 2019 17:27:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 849C66B0266; Tue,  7 May 2019 17:27:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 75F596B0271; Tue,  7 May 2019 17:27:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4A2826B000A
	for <linux-mm@kvack.org>; Tue,  7 May 2019 17:27:19 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id v13so2350740oie.12
        for <linux-mm@kvack.org>; Tue, 07 May 2019 14:27:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Ilo8gO1PWkcUZofYMK/PQNaZ6dgV/WeRBJ4EsjHLWhY=;
        b=RgSON5UDcabn39caNoOFM9TRwSWLJgrqtBVNN4qqoioPhDsV9V/2qVKopjK/VLSu+I
         aT/jhRAyx1jnv7YbAbAUMnSKJmAW2QBoyBNyPCUGd6jKMfhfDPgaGotDutOLJ+5y30eN
         xpSAtgBf6jtbreUMb8CHJF9N+bnOiWbapxrp5O/HPyTvyOIYdu4Gz718aENtYIwivczH
         QYH3Moi5dcSzHlLADfSCgKCgxdIsdtMhvNvcqF9FqUqtItzqukwOnIvZZweOxstEf1Yj
         wEoDlT2kKN55szo1e2GPrkLPxxHO6OVnsd6RvPRnv8HT539XwpMX2TzaiYIXXpkTrtCt
         lVTg==
X-Gm-Message-State: APjAAAUZOJ2AvKTnmBljTQzIkTOGI7hYsUwwx4neiSDplDysZTEsJ+4Q
	o6/AEKsWAa0nBILaGIGtwYixFAyeVYmsZ3l5G1OIqv92cStK+x3owkX8nkDduJapfWMrNapIxyj
	X8egLVfvis8JYLyYT/b3pECMZUUtOOoocAZ4d7ZS+y126jQZVuHbId3fhG0u9BaWHlQ==
X-Received: by 2002:aca:3093:: with SMTP id w141mr357888oiw.173.1557264438879;
        Tue, 07 May 2019 14:27:18 -0700 (PDT)
X-Received: by 2002:aca:3093:: with SMTP id w141mr357858oiw.173.1557264438111;
        Tue, 07 May 2019 14:27:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557264438; cv=none;
        d=google.com; s=arc-20160816;
        b=PP5sjN3uBbkN0fcU0ViDI0OfFEjsU4jOD3NXF3Ofk0j/WC/w85/7AO+dICgIb8wmI5
         aKH31X72CgSnguaokDfY2TpAtw2amAteI4nCiDrqNUeJmpbGFuAzUEbh+NyFmXaVv+yT
         vLXHruXWddrh+Ihdh/VcSbd5xsRL3XRzjcLT2H8dzU4+JBxgU16KQb8rDxWPg45newy5
         41S09D9/T4slibXEYHao/AbEqG/xvfdR3GRWnTCoh2F0pGVRZmjJLC+UINQeamki02iA
         AC10UFcEreBsuIZpZmz7jZvVchzYbHDEtQYFYSVBcFaymbenXhYZC/Str2P6JbT+6eu9
         DEAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Ilo8gO1PWkcUZofYMK/PQNaZ6dgV/WeRBJ4EsjHLWhY=;
        b=TRnT01j0Qof43It6ZDLCYqDkqcmeHlCubVm5c6dv6dbhZ6AGCXmOq2sVYDhWQjsTx6
         AaMBZM5rPOHYCTLqIOLyBEpOqm+7MBDmtOK46G9IgGz04WXekoHYbSe+v09qJMfAp6b6
         LrXVHgeoT/78++3Z3shwBEkHOKYuUmw6+ooLFmYgZOFkYUlIgkeNrg2A1Rdwd0SdGIRo
         GYSxyt3yDV2NPy/7vJUnDyQh52IKWz/fbIc6NsyueKP1xGQnVPXcxokwtqpxFNk7OK0A
         p+DrhGsaeVlKcUa6V/S2X3YL3J8QuAkki2obj9ild+DROCFNPLqWuCazPjGt6nV7ByXr
         Cd4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=ByBpM4rz;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g11sor6162758oia.110.2019.05.07.14.27.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 14:27:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=ByBpM4rz;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Ilo8gO1PWkcUZofYMK/PQNaZ6dgV/WeRBJ4EsjHLWhY=;
        b=ByBpM4rzcj0KLQCSJMTba88G4xlCaGSUA2kjKdZ426F15Q+rvisuUjrNKCKg64SatI
         hGfpL9+XJAVJAd7OK5x2X7bOH8UCONoqiDVzLbqIp/IwaUKRXv8SrDPC18TUUPCHF1gK
         2ha1HiuGirXRlCSSMKaKoHhE3E0pCkvMTucgiZDNVgY2pWXKQO4TeLkDOnsgzqC0ogLS
         OXmlSVXRnkw9NGgqDXboFi/m4xoLMtnx/yEKBYx7gU5J+BtPxhDhIoaniVzPXH31qT27
         CiUS/ula03FH7UD7iS0zY5et0vheHiUY5MatSWBPpGJ0F9FW8j6qp4fQGfelMW/FaD3I
         /X3w==
X-Google-Smtp-Source: APXvYqw1UieLnjdL3uGgndiZUbDSoney6ZAGnwarorW4h7jzSSrmLPgXgH79dv35ujhPqT1clUMPDGkfp9OwGUC0OOc=
X-Received: by 2002:aca:220f:: with SMTP id b15mr361431oic.73.1557264437776;
 Tue, 07 May 2019 14:27:17 -0700 (PDT)
MIME-Version: 1.0
References: <20190507183804.5512-1-david@redhat.com> <20190507183804.5512-7-david@redhat.com>
In-Reply-To: <20190507183804.5512-7-david@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 7 May 2019 14:27:07 -0700
Message-ID: <CAPcyv4gvuBfA0gJrChaUNR-8swU2Vq-UFJA9yRtsEbf2ajf7+w@mail.gmail.com>
Subject: Re: [PATCH v2 6/8] mm/memory_hotplug: Remove memory block devices
 before arch_remove_memory()
To: David Hildenbrand <david@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, 
	Linux-sh <linux-sh@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, 
	"mike.travis@hpe.com" <mike.travis@hpe.com>, Andrew Banman <andrew.banman@hpe.com>, 
	Ingo Molnar <mingo@kernel.org>, Alex Deucher <alexander.deucher@amd.com>, 
	"David S. Miller" <davem@davemloft.net>, Mark Brown <broonie@kernel.org>, 
	Chris Wilson <chris@chris-wilson.co.uk>, Oscar Salvador <osalvador@suse.de>, 
	Jonathan Cameron <Jonathan.Cameron@huawei.com>, Michal Hocko <mhocko@suse.com>, 
	Pavel Tatashin <pavel.tatashin@microsoft.com>, Arun KS <arunks@codeaurora.org>, 
	Mathieu Malaterre <malat@debian.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 7, 2019 at 11:39 AM David Hildenbrand <david@redhat.com> wrote:
>
> Let's factor out removing of memory block devices, which is only
> necessary for memory added via add_memory() and friends that created
> memory block devices. Remove the devices before calling
> arch_remove_memory().
>
> This finishes factoring out memory block device handling from
> arch_add_memory() and arch_remove_memory().

Also nice! makes it easier in the future for the "device-memory" use
case to not avoid messing up the typical memory hotplug flow.

>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: "Rafael J. Wysocki" <rafael@kernel.org>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Andrew Banman <andrew.banman@hpe.com>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Alex Deucher <alexander.deucher@amd.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Mark Brown <broonie@kernel.org>
> Cc: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Jonathan Cameron <Jonathan.Cameron@huawei.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Pavel Tatashin <pavel.tatashin@microsoft.com>
> Cc: Arun KS <arunks@codeaurora.org>
> Cc: Mathieu Malaterre <malat@debian.org>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  drivers/base/memory.c  | 39 +++++++++++++++++++--------------------
>  drivers/base/node.c    | 11 ++++++-----
>  include/linux/memory.h |  2 +-
>  include/linux/node.h   |  6 ++----
>  mm/memory_hotplug.c    |  5 +++--
>  5 files changed, 31 insertions(+), 32 deletions(-)
>
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 862c202a18ca..47ff49058d1f 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -756,32 +756,31 @@ int hotplug_memory_register(unsigned long start, unsigned long size)
>         return ret;
>  }
>
> -static int remove_memory_section(struct mem_section *section)
> +/*
> + * Remove memory block devices for the given memory area. Start and size
> + * have to be aligned to memory block granularity. Memory block devices
> + * have to be offline.
> + */
> +void hotplug_memory_unregister(unsigned long start, unsigned long size)
>  {
> +       unsigned long block_nr_pages = memory_block_size_bytes() >> PAGE_SHIFT;
> +       unsigned long start_pfn = PFN_DOWN(start);
> +       unsigned long end_pfn = start_pfn + (size >> PAGE_SHIFT);
>         struct memory_block *mem;
> +       unsigned long pfn;
>
> -       if (WARN_ON_ONCE(!present_section(section)))
> -               return;
> +       BUG_ON(!IS_ALIGNED(start, memory_block_size_bytes()));
> +       BUG_ON(!IS_ALIGNED(size, memory_block_size_bytes()));

Similar BUG_ON vs comments WARN_ON comments as the previous patch.

>
>         mutex_lock(&mem_sysfs_mutex);
> -
> -       /*
> -        * Some users of the memory hotplug do not want/need memblock to
> -        * track all sections. Skip over those.
> -        */
> -       mem = find_memory_block(section);
> -       if (!mem)
> -               goto out_unlock;
> -
> -       unregister_mem_sect_under_nodes(mem, __section_nr(section));
> -
> -       mem->section_count--;
> -       if (mem->section_count == 0)
> +       for (pfn = start_pfn; pfn != end_pfn; pfn += block_nr_pages) {
> +               mem = find_memory_block(__pfn_to_section(pfn));
> +               if (!mem)
> +                       continue;
> +               mem->section_count = 0;
> +               unregister_memory_block_under_nodes(mem);
>                 unregister_memory(mem);
> -       else
> -               put_device(&mem->dev);
> -
> -out_unlock:
> +       }
>         mutex_unlock(&mem_sysfs_mutex);
>  }
>
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 8598fcbd2a17..04fdfa99b8bc 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -801,9 +801,10 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, void *arg)
>         return 0;
>  }
>
> -/* unregister memory section under all nodes that it spans */
> -int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
> -                                   unsigned long phys_index)
> +/*
> + * Unregister memory block device under all nodes that it spans.
> + */
> +int unregister_memory_block_under_nodes(struct memory_block *mem_blk)
>  {
>         NODEMASK_ALLOC(nodemask_t, unlinked_nodes, GFP_KERNEL);
>         unsigned long pfn, sect_start_pfn, sect_end_pfn;
> @@ -816,8 +817,8 @@ int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
>                 return -ENOMEM;
>         nodes_clear(*unlinked_nodes);
>
> -       sect_start_pfn = section_nr_to_pfn(phys_index);
> -       sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
> +       sect_start_pfn = section_nr_to_pfn(mem_blk->start_section_nr);
> +       sect_end_pfn = section_nr_to_pfn(mem_blk->end_section_nr);
>         for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
>                 int nid;
>
> diff --git a/include/linux/memory.h b/include/linux/memory.h
> index 95505fbb5f85..aa236c2a0466 100644
> --- a/include/linux/memory.h
> +++ b/include/linux/memory.h
> @@ -112,7 +112,7 @@ extern void unregister_memory_notifier(struct notifier_block *nb);
>  extern int register_memory_isolate_notifier(struct notifier_block *nb);
>  extern void unregister_memory_isolate_notifier(struct notifier_block *nb);
>  int hotplug_memory_register(unsigned long start, unsigned long size);
> -extern void unregister_memory_section(struct mem_section *);
> +void hotplug_memory_unregister(unsigned long start, unsigned long size);
>  extern int memory_dev_init(void);
>  extern int memory_notify(unsigned long val, void *v);
>  extern int memory_isolate_notify(unsigned long val, void *v);
> diff --git a/include/linux/node.h b/include/linux/node.h
> index 1a557c589ecb..02a29e71b175 100644
> --- a/include/linux/node.h
> +++ b/include/linux/node.h
> @@ -139,8 +139,7 @@ extern int register_cpu_under_node(unsigned int cpu, unsigned int nid);
>  extern int unregister_cpu_under_node(unsigned int cpu, unsigned int nid);
>  extern int register_mem_sect_under_node(struct memory_block *mem_blk,
>                                                 void *arg);
> -extern int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
> -                                          unsigned long phys_index);
> +extern int unregister_memory_block_under_nodes(struct memory_block *mem_blk);
>
>  extern int register_memory_node_under_compute_node(unsigned int mem_nid,
>                                                    unsigned int cpu_nid,
> @@ -176,8 +175,7 @@ static inline int register_mem_sect_under_node(struct memory_block *mem_blk,
>  {
>         return 0;
>  }
> -static inline int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
> -                                                 unsigned long phys_index)
> +static inline int unregister_memory_block_under_nodes(struct memory_block *mem_blk)
>  {
>         return 0;
>  }
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 107f72952347..527fe4f9c620 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -519,8 +519,6 @@ static void __remove_section(struct zone *zone, struct mem_section *ms,
>         if (WARN_ON_ONCE(!valid_section(ms)))
>                 return;
>
> -       unregister_memory_section(ms);
> -
>         scn_nr = __section_nr(ms);
>         start_pfn = section_nr_to_pfn((unsigned long)scn_nr);
>         __remove_zone(zone, start_pfn);
> @@ -1844,6 +1842,9 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
>         memblock_free(start, size);
>         memblock_remove(start, size);
>
> +       /* remove memory block devices before removing memory */
> +       hotplug_memory_unregister(start, size);
> +
>         arch_remove_memory(nid, start, size, NULL);
>         __release_memory_resource(start, size);

Other than the BUG_ON concern you can add

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

