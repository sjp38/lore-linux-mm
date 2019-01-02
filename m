Return-Path: <SRS0=6aBQ=PK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4A42C43612
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 06:47:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 741232089F
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 06:47:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AarWDTTi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 741232089F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 085D08E000D; Wed,  2 Jan 2019 01:47:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00AC18E0002; Wed,  2 Jan 2019 01:47:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E14BD8E000D; Wed,  2 Jan 2019 01:47:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 860898E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 01:47:48 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id 39so31574815edq.13
        for <linux-mm@kvack.org>; Tue, 01 Jan 2019 22:47:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=dIoU4+9M1RTnqRONsQUWgZIa15vjsfmwfT62Wv+5qbA=;
        b=NUf3QwUydY6ABrPAlcM1BiBd6QDFMvGiDjbpntz/35EAqUVAhrHeFl7JDdC95HJ9G2
         p3CgJ4BhDFO6Ocb328XV9x/qLNqRTDYBB+l2h5PVThMu3WyA6qiPeEJw5DBDxumlq0lV
         O/Sabf43SgxVTgWhja4ke+qsafRrIoz/jaN4Keuwwl6I8jZzndsekInCvBfz20HfWcKQ
         CpVDEVoqP721P/pcZRCKCM1FdRgyUPE8g+0ZBLMx8OFLr5iiz67jMqF9e7VYmZD4NkQ6
         jMIi85TSiLLZNKzoysWHigvrliRnnSGBTdjcKdrnE/WG7pmL171m5wf5auAQLvNMvQhg
         yYVQ==
X-Gm-Message-State: AA+aEWa5pni5SQaHwHlr8ALSE/YAUOq4gjjpJZuwdHBJ6HGH3DYgH+lG
	NSul7NICYLMRNO2wbvVKgTNdjYij7WFQkHHCXW9TbP8LRywTMW7GxoO/6pAkx1keqc0o+Z96uOc
	YfgT5Z8+mrVqXGmNC5jv+rJxR9uoq4HVcUn8uyjWuzbHDXR+lyF05A/urUhyLRPriLGpSup3G4M
	hIAxXG6gR5YAfBH8RkWXlSwyRM2gSgeLM1oKaACYWIWsvwchmW/z9ZqC1SsQp3pTyNIi6Gn+4Uj
	xv4RqEsjbSpASd0rbDS2pmzSBIsSRJgqahzu2SIvj/UjSMH8Dfxek6pOm0zSpqNCWKPXoSmV1G2
	abIPJ4hQCRZNwikxCZ3yVuZ+0bVCsk8irw8cAsz54YKGc8fGCxYtrQaf3w+hLWfsPWY6vQFXZNb
	T
X-Received: by 2002:a17:906:881:: with SMTP id n1-v6mr31319743eje.7.1546411667989;
        Tue, 01 Jan 2019 22:47:47 -0800 (PST)
X-Received: by 2002:a17:906:881:: with SMTP id n1-v6mr31319700eje.7.1546411666783;
        Tue, 01 Jan 2019 22:47:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546411666; cv=none;
        d=google.com; s=arc-20160816;
        b=DER3YHcHKb2AZVqWFXrgBYyvBLLTWlN+06bw5Uyu9j0f2y9w1tJ8C55BreaaK6lwXk
         EPYsbFypX8mbZB6sP61IO8C1n8uyLfzJhDorBuszHo+w8cDmV2K73tT42glPJLS4dZVj
         /iGLc6dMrYpqs163hJh+qEFuOozfUVRnEn2sJR28Yz3s4MbSIDAwHdVLOCoo3qjfT7iu
         Klq2kfwvkGi11TJmmXpXJSZSjdNjYyPcSjXUaa69CUMeEXpiBnCOUdwQaJOOOE+a0bBy
         Yl65vGLLFioEq6xkZIxvx/ZzN92a6B19Wr8O4NJajvxhO2Rq5BPE4SOvXJusigvW30RG
         F3nw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=dIoU4+9M1RTnqRONsQUWgZIa15vjsfmwfT62Wv+5qbA=;
        b=fkZF4sa0ZrNUD7LlRGkePj3wwp1k7XKPOKyNKh039ZK8gS9Zv/mYbsrWyyj0/8CJ/W
         VYzposHc+XgaRwfKFIErxCdWcwfqwBJJsA3C0PWbpzGB1fEJkPYxkW0JPjFIv+3gmIm/
         2G+cmo1Or2VbVxj+SPBClCkn5GxEybudFlKA8UeUK8AtAFx1jrsh9ydsTgWrgiG4rR+N
         816Xflz+hf8R7t0JfEENa96yBzc8j+UgqOjl1xeuTfaFCFRKSGiS/XvcoH+/Ivms+2ec
         drxXuiQgC37nVCPj2/+xQoy9aPMLqW43sY4tSgGCPOjpANlOSyopVCO7etDhh54V6LC6
         Y1Rw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AarWDTTi;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k20sor28797345ede.22.2019.01.01.22.47.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 01 Jan 2019 22:47:46 -0800 (PST)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AarWDTTi;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=dIoU4+9M1RTnqRONsQUWgZIa15vjsfmwfT62Wv+5qbA=;
        b=AarWDTTimcyTaaLhv3O3qNyVdqSMXAd9AKZv2Zp/hM4Hb4b5/xL842xDD6rsCeGnur
         hEnQmGzkGCGTaNA4lGhwpOk5NFVmDQcidK1VnJ9TvvrHIkzBVZvatHthi6Oebd+lKE32
         adepKJHMrFZn9gT5oJvzO5wdK5/5dZ0803IDW1oFGmsGQatYNHEJRuebzVl4RUSaoOPk
         BC1vEVvMalS63mqT7fG9kAtMJiQ+RtFm+QE/1KtO/jYFq0wG245rrTCS7OJlc+zp6Sme
         t01XU68hs7t6DSjmoEnKLvcpkMgEHaKWQTR4GuG1AcAwEoreIa2uXmC/HIdMq2ghhnxl
         3SPw==
X-Google-Smtp-Source: AFSGD/Xy5gHqp6/th8sKAa40TN//CqSZiQlNjczk+klhyErmRPCXd/3cZY70Ldx+zAwBfXoRPCp0fylZ7KssazGUmBs=
X-Received: by 2002:a50:d551:: with SMTP id f17mr37921398edj.87.1546411666210;
 Tue, 01 Jan 2019 22:47:46 -0800 (PST)
MIME-Version: 1.0
References: <1545966002-3075-1-git-send-email-kernelfans@gmail.com>
 <1545966002-3075-2-git-send-email-kernelfans@gmail.com> <20181231084018.GA28478@rapoport-lnx>
In-Reply-To: <20181231084018.GA28478@rapoport-lnx>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Wed, 2 Jan 2019 14:47:34 +0800
Message-ID:
 <CAFgQCTvQnj7zReFvH_gmfVJdPXE325o+z4Xx76fupvsLR_7H2A@mail.gmail.com>
Subject: Re: [PATCHv3 1/2] mm/memblock: extend the limit inferior of bottom-up
 after parsing hotplug attr
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-acpi@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org, 
	Tang Chen <tangchen@cn.fujitsu.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Michal Hocko <mhocko@suse.com>, Jonathan Corbet <corbet@lwn.net>, 
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, 
	Nicholas Piggin <npiggin@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, 
	Daniel Vacek <neelx@redhat.com>, Mathieu Malaterre <malat@debian.org>, Stefan Agner <stefan@agner.ch>, 
	Dave Young <dyoung@redhat.com>, Baoquan He <bhe@redhat.com>, yinghai@kernel.org, 
	vgoyal@redhat.com, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190102064734.RzPZdKQEmGjvXr3Uckrjdes93lyZHOguS1peZQE1ERs@z>

On Mon, Dec 31, 2018 at 4:40 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
>
> On Fri, Dec 28, 2018 at 11:00:01AM +0800, Pingfan Liu wrote:
> > The bottom-up allocation style is introduced to cope with movable_node,
> > where the limit inferior of allocation starts from kernel's end, due to
> > lack of knowledge of memory hotplug info at this early time. But if later,
> > hotplug info has been got, the limit inferior can be extend to 0.
> > 'kexec -c' prefers to reuse this style to alloc mem at lower address,
> > since if the reserved region is beyond 4G, then it requires extra mem
> > (default is 16M) for swiotlb.
>
> I fail to understand why the availability of memory hotplug information
> would allow to extend the lower limit of bottom-up memblock allocations
> below the kernel. The memory in the physical range [0, kernel_start) can be
> allocated as soon as the kernel memory is reserved.
>
Yes, the  [0, kernel_start) can be allocated at this time by some func
e.g. memblock_reserve(). But there is trick. For the func like
memblock_find_in_range(), this is hotplug attr checking ,,it will
check the hotmovable attr in __next_mem_range()
{
if (movable_node_is_enabled() && memblock_is_hotpluggable(m))
continue
}.  So the movable memory can be safely skipped.

Thanks for your kindly review.

Regards,
Pingfan

> The extents of the memory node hosting the kernel image can be used to
> limit memblok allocations from that particular node, even in top-down mode.
>
> > Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
> > Cc: Tang Chen <tangchen@cn.fujitsu.com>
> > Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> > Cc: Len Brown <lenb@kernel.org>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Jonathan Corbet <corbet@lwn.net>
> > Cc: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
> > Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
> > Cc: Nicholas Piggin <npiggin@gmail.com>
> > Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Cc: Daniel Vacek <neelx@redhat.com>
> > Cc: Mathieu Malaterre <malat@debian.org>
> > Cc: Stefan Agner <stefan@agner.ch>
> > Cc: Dave Young <dyoung@redhat.com>
> > Cc: Baoquan He <bhe@redhat.com>
> > Cc: yinghai@kernel.org,
> > Cc: vgoyal@redhat.com
> > Cc: linux-kernel@vger.kernel.org
> > ---
> >  drivers/acpi/numa.c      |  4 ++++
> >  include/linux/memblock.h |  1 +
> >  mm/memblock.c            | 58 +++++++++++++++++++++++++++++-------------------
> >  3 files changed, 40 insertions(+), 23 deletions(-)
> >
> > diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
> > index 2746994..3eea4e4 100644
> > --- a/drivers/acpi/numa.c
> > +++ b/drivers/acpi/numa.c
> > @@ -462,6 +462,10 @@ int __init acpi_numa_init(void)
> >
> >               cnt = acpi_table_parse_srat(ACPI_SRAT_TYPE_MEMORY_AFFINITY,
> >                                           acpi_parse_memory_affinity, 0);
> > +
> > +#if defined(CONFIG_X86) || defined(CONFIG_ARM64)
> > +             mark_mem_hotplug_parsed();
> > +#endif
> >       }
> >
> >       /* SLIT: System Locality Information Table */
> > diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> > index aee299a..d89ed9e 100644
> > --- a/include/linux/memblock.h
> > +++ b/include/linux/memblock.h
> > @@ -125,6 +125,7 @@ int memblock_reserve(phys_addr_t base, phys_addr_t size);
> >  void memblock_trim_memory(phys_addr_t align);
> >  bool memblock_overlaps_region(struct memblock_type *type,
> >                             phys_addr_t base, phys_addr_t size);
> > +void mark_mem_hotplug_parsed(void);
> >  int memblock_mark_hotplug(phys_addr_t base, phys_addr_t size);
> >  int memblock_clear_hotplug(phys_addr_t base, phys_addr_t size);
> >  int memblock_mark_mirror(phys_addr_t base, phys_addr_t size);
> > diff --git a/mm/memblock.c b/mm/memblock.c
> > index 81ae63c..a3f5e46 100644
> > --- a/mm/memblock.c
> > +++ b/mm/memblock.c
> > @@ -231,6 +231,12 @@ __memblock_find_range_top_down(phys_addr_t start, phys_addr_t end,
> >       return 0;
> >  }
> >
> > +static bool mem_hotmovable_parsed __initdata_memblock;
> > +void __init_memblock mark_mem_hotplug_parsed(void)
> > +{
> > +     mem_hotmovable_parsed = true;
> > +}
> > +
> >  /**
> >   * memblock_find_in_range_node - find free area in given range and node
> >   * @size: size of free area to find
> > @@ -259,7 +265,7 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t size,
> >                                       phys_addr_t end, int nid,
> >                                       enum memblock_flags flags)
> >  {
> > -     phys_addr_t kernel_end, ret;
> > +     phys_addr_t kernel_end, ret = 0;
> >
> >       /* pump up @end */
> >       if (end == MEMBLOCK_ALLOC_ACCESSIBLE)
> > @@ -270,34 +276,40 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t size,
> >       end = max(start, end);
> >       kernel_end = __pa_symbol(_end);
> >
> > -     /*
> > -      * try bottom-up allocation only when bottom-up mode
> > -      * is set and @end is above the kernel image.
> > -      */
> > -     if (memblock_bottom_up() && end > kernel_end) {
> > -             phys_addr_t bottom_up_start;
> > +     if (memblock_bottom_up()) {
> > +             phys_addr_t bottom_up_start = start;
> >
> > -             /* make sure we will allocate above the kernel */
> > -             bottom_up_start = max(start, kernel_end);
> > -
> > -             /* ok, try bottom-up allocation first */
> > -             ret = __memblock_find_range_bottom_up(bottom_up_start, end,
> > -                                                   size, align, nid, flags);
> > -             if (ret)
> > +             if (mem_hotmovable_parsed) {
> > +                     ret = __memblock_find_range_bottom_up(
> > +                             bottom_up_start, end, size, align, nid,
> > +                             flags);
> >                       return ret;
> >
> >               /*
> > -              * we always limit bottom-up allocation above the kernel,
> > -              * but top-down allocation doesn't have the limit, so
> > -              * retrying top-down allocation may succeed when bottom-up
> > -              * allocation failed.
> > -              *
> > -              * bottom-up allocation is expected to be fail very rarely,
> > -              * so we use WARN_ONCE() here to see the stack trace if
> > -              * fail happens.
> > +              * if mem hotplug info is not parsed yet, try bottom-up
> > +              * allocation with @end above the kernel image.
> >                */
> > -             WARN_ONCE(IS_ENABLED(CONFIG_MEMORY_HOTREMOVE),
> > +             } else if (!mem_hotmovable_parsed && end > kernel_end) {
> > +                     /* make sure we will allocate above the kernel */
> > +                     bottom_up_start = max(start, kernel_end);
> > +                     ret = __memblock_find_range_bottom_up(
> > +                             bottom_up_start, end, size, align, nid,
> > +                             flags);
> > +                     if (ret)
> > +                             return ret;
> > +                     /*
> > +                      * we always limit bottom-up allocation above the
> > +                      * kernel, but top-down allocation doesn't have
> > +                      * the limit, so retrying top-down allocation may
> > +                      * succeed when bottom-up allocation failed.
> > +                      *
> > +                      * bottom-up allocation is expected to be fail
> > +                      * very rarely, so we use WARN_ONCE() here to see
> > +                      * the stack trace if fail happens.
> > +                      */
> > +                     WARN_ONCE(IS_ENABLED(CONFIG_MEMORY_HOTREMOVE),
> >                         "memblock: bottom-up allocation failed, memory hotremove may be affected\n");
> > +             }
> >       }
> >
> >       return __memblock_find_range_top_down(start, end, size, align, nid,
> > --
> > 2.7.4
> >
>
> --
> Sincerely yours,
> Mike.
>

