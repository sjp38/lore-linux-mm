Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0ED15C76191
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 12:20:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95A2221783
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 12:20:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="TZjOKys0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95A2221783
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 02FAB6B0003; Thu, 18 Jul 2019 08:20:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F24A26B0005; Thu, 18 Jul 2019 08:19:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DEA618E0001; Thu, 18 Jul 2019 08:19:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 92E3C6B0003
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 08:19:59 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id l14so19863304edw.20
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 05:19:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=CCVHqVtcDr9kxRQz1YfpzaVckBtPbq59VjeQ1p3zOVc=;
        b=QTPXqwo95coH3sYkxRjo8WVxb3EoqkKzwJ3cPlJmv0sJRhTmRx4RkRJ+rUMSojFkXe
         sbuyKzLy/ItX3jyXvma61C6XshDvvxgGmLFLNCIsMwF3wvnV1b6JDAVpKx1dp4VCBDg9
         PZzyUKkSRa/MIUViyinurEfd04rjOQ2/xIVeh/n/UdOAfM0OoQ7rutRQcMixvj1fDeKK
         A1lYrGEIwjNg7c/7hRhwaG4/lsdcuq0IN4sdL5hHfNqUDq3flhWdavK2TQy3Eto8uFGe
         w07c9anRAtMf1T+RXGdeAb18/7q1aquK93e8d7YSp69AXdTBRvBZZ+n6pYGUxvJ6OJLP
         KCyg==
X-Gm-Message-State: APjAAAUhpGA1YFXe/zIM7EcDpMzV494yqukHs606e+rCjvZ1fvJy+iGc
	gv54db+DaIH24UQjUSBDQhLLRme+0aNkTvwQ4KsErXNxgXYcOQlk3is+ceLQ5TDT8PRS8o6WSQm
	jCCAaelCGG/ver5xuIozn0E3KLhjY3pDLxIjbB6P/6Esqx4675BbtxNthLMpivhP5kA==
X-Received: by 2002:a50:ac24:: with SMTP id v33mr40322772edc.30.1563452399154;
        Thu, 18 Jul 2019 05:19:59 -0700 (PDT)
X-Received: by 2002:a50:ac24:: with SMTP id v33mr40322685edc.30.1563452398095;
        Thu, 18 Jul 2019 05:19:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563452398; cv=none;
        d=google.com; s=arc-20160816;
        b=XO0tfx3Mdi1Nf3Zm6lg/PJ35UPlTP2sg4oHj/fncnUGm079j6qns8IM+iIycmhvlHD
         w07I1Xq8nARbAMzUgUhByg0ZwgL38Bi2bCH9pyalDQNhwmEq8RTpxfDdm5I3mS9GIvTb
         jTX6h09wNh4717xnDjgDn/Sr5l+mUpWUoaEa9OzI1vFmYHLod+9Cl5vR9Ap4LJRBnb1H
         m0U27kMJWuObQwnPdr05S7Vhrl8S294m4qzQ0LTUNJYmigyxJoFZBYIymDbwLrRHFQRb
         6hJtwbdwlnm0H5dSVCZ2tX8y7ngi9vZ4mazVvEkBw6Lx202rjeeBG1XO+pJEJoPc9kjU
         11MA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=CCVHqVtcDr9kxRQz1YfpzaVckBtPbq59VjeQ1p3zOVc=;
        b=mRXinqVizR7zqQ07/O/P/cYi9TegpoJ0pMV+RPl3m/hZ7ZLt+6JgnJpqvf4o+Z/Z2h
         n7brXvEOHX3mXzAAdoe7yWfmwpYkdGxA7SOHQULa9o7FRDbaLlkfCBDxl5WWDUuERiV4
         lMdX8p9IgQMh5K+jOFmslSIH/rPOmrS/hlD3kQpovU0+2pqACcq3ysliUr9JfmH6tPXP
         jAlmuoWt/ZoNqVYf+q6ZzQlLLNTbQ1Hc/8aLCN7oFtn/C0QhUWEVHfnGYRFQoBfKzpaf
         +mhu+aMBoQ76s90En9OXekjKdiy8xCuUUR1nZldqUOP2fKfB2d12OKHKCL3ZdoFjMKJY
         J49Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=TZjOKys0;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x8sor9018398eju.28.2019.07.18.05.19.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Jul 2019 05:19:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=TZjOKys0;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=CCVHqVtcDr9kxRQz1YfpzaVckBtPbq59VjeQ1p3zOVc=;
        b=TZjOKys03SMFxMLBoi3A5eP5IIETYuLZHVfNo9Sr5/oPvhYZ0sb9eu01Cww8CLUsEd
         WPZF0Q9MGYDAvp2lkAO7a9++fepsHkgI/ajVgs70C0p5gEz5P7HanQfcIB6qVyuNqz9z
         iJo5Z2/SVIU8BaIXJRS/33G0P3lByvJnZg1uWKv6z7eFCAEI6bXWkrmS0YjHAq6oDLCP
         2E0AzCzK8vwAv6Y6HWbul7rfc//Qds6XVQOCwcWwrAQj7cQHoK0qXszAT1ErTmeHBDCo
         C+vJpLIuTeehs4DMEMSuV/71VgxMyynAKxeEUBkszIZI3fPE53lLKtfq+U319K1kPf9I
         JPbQ==
X-Google-Smtp-Source: APXvYqzcA8/9pmEX4K9HZSZ6a8HBFZKEBUeGXpnUZGdqw3SL92Bxma0PiWv2EMFLoPf3cMiLE1hgkjSOYVvuQa/1ork=
X-Received: by 2002:a17:906:5409:: with SMTP id q9mr36460845ejo.209.1563452397474;
 Thu, 18 Jul 2019 05:19:57 -0700 (PDT)
MIME-Version: 1.0
References: <20190718024133.3873-1-leonardo@linux.ibm.com>
In-Reply-To: <20190718024133.3873-1-leonardo@linux.ibm.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Thu, 18 Jul 2019 08:19:46 -0400
Message-ID: <CA+CK2bBu7DnG73SaBDwf9cBceNvKnZDEqA-gBJmKC9K_rqgO+A@mail.gmail.com>
Subject: Re: [PATCH 1/1] mm/memory_hotplug: Adds option to hot-add memory in ZONE_MOVABLE
To: Leonardo Bras <leonardo@linux.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.ibm.com>, 
	Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Pasha Tatashin <Pavel.Tatashin@microsoft.com>, 
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 17, 2019 at 10:42 PM Leonardo Bras <leonardo@linux.ibm.com> wrote:
>
> Adds an option on kernel config to make hot-added memory online in
> ZONE_MOVABLE by default.
>
> This would be great in systems with MEMORY_HOTPLUG_DEFAULT_ONLINE=y by
> allowing to choose which zone it will be auto-onlined

This is a desired feature. From reading the code it looks to me that
auto-selection of online method type should be done in
memory_subsys_online().

When it is called from device online, mem->online_type should be -1:

if (mem->online_type < 0)
     mem->online_type = MMOP_ONLINE_KEEP;

Change it to:
if (mem->online_type < 0)
     mem->online_type = MMOP_DEFAULT_ONLINE_TYPE;

And in "linux/memory_hotplug.h"
#ifdef CONFIG_MEMORY_HOTPLUG_MOVABLE
#define MMOP_DEFAULT_ONLINE_TYPE MMOP_ONLINE_MOVABLE
#else
#define MMOP_DEFAULT_ONLINE_TYPE MMOP_ONLINE_KEEP
#endif

Could be expanded to support MMOP_ONLINE_KERNEL as well.

Pasha

>
> Signed-off-by: Leonardo Bras <leonardo@linux.ibm.com>
> ---
>  drivers/base/memory.c |  3 +++
>  mm/Kconfig            | 14 ++++++++++++++
>  2 files changed, 17 insertions(+)
>
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index f180427e48f4..378b585785c1 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -670,6 +670,9 @@ static int init_memory_block(struct memory_block **memory,
>         mem->state = state;
>         start_pfn = section_nr_to_pfn(mem->start_section_nr);
>         mem->phys_device = arch_get_memory_phys_device(start_pfn);
> +#ifdef CONFIG_MEMORY_HOTPLUG_MOVABLE
> +       mem->online_type = MMOP_ONLINE_MOVABLE;
> +#endif
>
>         ret = register_memory(mem);
>
> diff --git a/mm/Kconfig b/mm/Kconfig
> index f0c76ba47695..74e793720f43 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -180,6 +180,20 @@ config MEMORY_HOTREMOVE
>         depends on MEMORY_HOTPLUG && ARCH_ENABLE_MEMORY_HOTREMOVE
>         depends on MIGRATION
>
> +config MEMORY_HOTPLUG_MOVABLE
> +       bool "Enhance the likelihood of hot-remove"
> +       depends on MEMORY_HOTREMOVE
> +       help
> +         This option sets the hot-added memory zone to MOVABLE which
> +         drastically reduces the chance of a hot-remove to fail due to
> +         unmovable memory segments. Kernel memory can't be allocated in
> +         this zone.
> +
> +         Say Y here if you want to have better chance to hot-remove memory
> +         that have been previously hot-added.
> +         Say N here if you want to make all hot-added memory available to
> +         kernel space.
> +
>  # Heavily threaded applications may benefit from splitting the mm-wide
>  # page_table_lock, so that faults on different parts of the user address
>  # space can be handled with less contention: split it at this NR_CPUS.
> --
> 2.20.1
>

On Wed, Jul 17, 2019 at 10:42 PM Leonardo Bras <leonardo@linux.ibm.com> wrote:
>
> Adds an option on kernel config to make hot-added memory online in
> ZONE_MOVABLE by default.
>
> This would be great in systems with MEMORY_HOTPLUG_DEFAULT_ONLINE=y by
> allowing to choose which zone it will be auto-onlined
>
> Signed-off-by: Leonardo Bras <leonardo@linux.ibm.com>
> ---
>  drivers/base/memory.c |  3 +++
>  mm/Kconfig            | 14 ++++++++++++++
>  2 files changed, 17 insertions(+)
>
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index f180427e48f4..378b585785c1 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -670,6 +670,9 @@ static int init_memory_block(struct memory_block **memory,
>         mem->state = state;
>         start_pfn = section_nr_to_pfn(mem->start_section_nr);
>         mem->phys_device = arch_get_memory_phys_device(start_pfn);
> +#ifdef CONFIG_MEMORY_HOTPLUG_MOVABLE
> +       mem->online_type = MMOP_ONLINE_MOVABLE;
> +#endif
>
>         ret = register_memory(mem);
>
> diff --git a/mm/Kconfig b/mm/Kconfig
> index f0c76ba47695..74e793720f43 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -180,6 +180,20 @@ config MEMORY_HOTREMOVE
>         depends on MEMORY_HOTPLUG && ARCH_ENABLE_MEMORY_HOTREMOVE
>         depends on MIGRATION
>
> +config MEMORY_HOTPLUG_MOVABLE
> +       bool "Enhance the likelihood of hot-remove"
> +       depends on MEMORY_HOTREMOVE
> +       help
> +         This option sets the hot-added memory zone to MOVABLE which
> +         drastically reduces the chance of a hot-remove to fail due to
> +         unmovable memory segments. Kernel memory can't be allocated in
> +         this zone.
> +
> +         Say Y here if you want to have better chance to hot-remove memory
> +         that have been previously hot-added.
> +         Say N here if you want to make all hot-added memory available to
> +         kernel space.
> +
>  # Heavily threaded applications may benefit from splitting the mm-wide
>  # page_table_lock, so that faults on different parts of the user address
>  # space can be handled with less contention: split it at this NR_CPUS.
> --
> 2.20.1
>

