Return-Path: <SRS0=B01V=PM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 327F2C43387
	for <linux-mm@archiver.kernel.org>; Fri,  4 Jan 2019 06:00:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A97682070D
	for <linux-mm@archiver.kernel.org>; Fri,  4 Jan 2019 06:00:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="u/aiuFGs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A97682070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0233B8E00C3; Fri,  4 Jan 2019 01:00:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F15E88E00AE; Fri,  4 Jan 2019 01:00:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E033C8E00C3; Fri,  4 Jan 2019 01:00:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 728778E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 01:00:01 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id f17so34675661edm.20
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 22:00:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=VlaY4M0zxwRyfsuAwMFu6zd+oEZui7KIU9HQyg9FcN8=;
        b=Uo3SX/J5Kagh7U3BAuHCQlHydl1YtWDJZnSbmDl9a2SEkc+JKYWDvYiuMjSQNeRcEA
         tHuGnnb2C1xYfmpdqDfQJESW5pVnNd9Pz2nv4an0x7m4pcYkJWOqZph6U+xH6N+JW7DR
         vZyTnp0QM6oioy4KewiMA6Y7feeGNnvsH86EeZEPouyXA0m/ICLR1bzM1RvPc+cE4RT7
         94jiIf1WSI3d5FqW5iEmKZk/cY8CKI1jUpm8HR1whaW6fLuhb28YlqHstHmRSuGJLKa2
         sEis5Vq6QVCfOFDqAseVxRxfS+fJA+jErbEgiZTV1PCX3yLgDw3ivzeFAuzrd7nPBjwM
         fxDg==
X-Gm-Message-State: AA+aEWbtIf/QmiYTwYYmYWHYRish49tSL28tCLOagHL75xK8+GxB9qwl
	X96GVtdKNobwBVC2lBn6Lv8O2HgIW6kL/B5Y6kMvfTTIgPkarLiLdAEUCYNEwIVHgQPl+lcpO83
	eeWTeZeBwNtMjlkWFbbvKsCgKckzbQ/7JrIH2Yk7pQezBB6mjEBmgwZWh4XJP/acMRY2BhCbkFa
	JaRpP6mmUvYbTFr1TBJgYKPbFc140bfv8Go6d+uvaK+waGbhxlR8DpG5RTqyX0vRhQRgUmLo0w9
	exXMESdmuvqF2dFztrZUjqzNr+Wf9Lhxlnso2WyZslOCx+4PxdK3XyGTZ8DVnEa+JtHinRE1aRY
	pDIByMpKICv87e7knGX8xGQ20MINAQTeO7fb2rNNRPIbFNW4Cs+ao2bZQjyz3rlkvmzfLETWXl6
	p
X-Received: by 2002:a17:906:6308:: with SMTP id p8-v6mr37854483ejk.100.1546581600655;
        Thu, 03 Jan 2019 22:00:00 -0800 (PST)
X-Received: by 2002:a17:906:6308:: with SMTP id p8-v6mr37854445ejk.100.1546581599288;
        Thu, 03 Jan 2019 21:59:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546581599; cv=none;
        d=google.com; s=arc-20160816;
        b=waGT3d2IMpENCwQuWuCg5lo2L508ZcznjVXgr5rGg0HpQGZU8Nh45bR9B9Q9/U86BC
         JxVpvSb0XZtdmz9O4x458dYNbWdaEf+jysOlrozO73mxs1aq7pgH1yQCkWla4sGb2HxA
         RxmsE3RGxKIknwpzkahKpUC7+inFBqWDEDSQbgL6SYRqbGhPowug2Q3O+0dBkUw/mZKu
         tND5sVS8+cuiOorcGUvFl74m9+QR5E1FoSNcKOUzPcaPNAHzf5VNYyEeKCKaPwlOrYQT
         BifezcsZ0XgZFEwbqLj6FClrHL+dgd+4G12k4CPD9DEOME8ehVIu3TgkCX6isrxPIA2g
         qTXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=VlaY4M0zxwRyfsuAwMFu6zd+oEZui7KIU9HQyg9FcN8=;
        b=U1YO7aGQNGMClV6+RmMLl3yGNBAEhKWrfp1nkusgj/QqfBlUH6aKyGTRoP3oThzylT
         fir6xlOxhlI8H5+OdYa9dgr/2jwI0AttlHqijE38WZiqgFD8M5sM/tdN1WQ8JtRX5nDr
         Qgv4An52XhRemhLY4mA8vApxV9dv3AlV9tp29aZBHVa/CRW2B4xlFW6tJnF7NVsgWqsf
         TlJHvsUQ6b6n/0HeEcxnMWYhO0Fh+S7FmLz7T15y+OmY2myvJGdCbuUpU62Wa6TQhpp6
         mx7tF2iWIGUl1wKd/1QEGlBEBRny5ATlhcw76tZzR8Hmwk9E/SV8V8DfregsyTlEqkzq
         /SZg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="u/aiuFGs";
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g5-v6sor14811995ejp.23.2019.01.03.21.59.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 Jan 2019 21:59:59 -0800 (PST)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="u/aiuFGs";
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=VlaY4M0zxwRyfsuAwMFu6zd+oEZui7KIU9HQyg9FcN8=;
        b=u/aiuFGsdvIgOkvgqzLuZmFnUmwgHbVR6XfiO8he+SnZ1Kaci/Cg+6rANw7AMrZEey
         aMrALbI1dcV5FDaAYNxhEHgtbP5uTwtuMcHJ7mtxGOuFKvQPtz7Q8kJ/MGBp9rZrLwFW
         Mgh3K2geTj8QV9XtyNTpWWz52n+7ghq63Y2KUnZRSY60S6jpull3MSXiwVufoeFtMToD
         ejc+bhUvLXTmsRO/YfO570BknnTPk1xr71vdGhWJN9KXAPofzV2+774EmiMk24w03o0n
         LLBcJc/mXXcpWAOmrN95Ahv1IpcmXaaZC+lBxxCjLmtQ+8dHT5DLkaV12Nj5j5UkLils
         3LtA==
X-Google-Smtp-Source: AFSGD/Wtl0qKT22yQYX9MzhiMPEFpprDmgpAdYtc6KUgAa1u+4oFIdVQr6CxN8jgFUOlL1z6zYXF6+iwtIc/JpPZrus=
X-Received: by 2002:a17:906:1ec4:: with SMTP id m4-v6mr37737447ejj.35.1546581598663;
 Thu, 03 Jan 2019 21:59:58 -0800 (PST)
MIME-Version: 1.0
References: <1545966002-3075-1-git-send-email-kernelfans@gmail.com>
 <1545966002-3075-2-git-send-email-kernelfans@gmail.com> <20181231084018.GA28478@rapoport-lnx>
 <CAFgQCTvQnj7zReFvH_gmfVJdPXE325o+z4Xx76fupvsLR_7H2A@mail.gmail.com>
 <20190102092749.GA22664@rapoport-lnx> <20190102101804.GD1990@MiWiFi-R3L-srv>
In-Reply-To: <20190102101804.GD1990@MiWiFi-R3L-srv>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Fri, 4 Jan 2019 13:59:46 +0800
Message-ID:
 <CAFgQCTsf2jYuZDaVRY0KH2gZWEeK9iPKqSwTwFBJaqiCaN3x3w@mail.gmail.com>
Subject: Re: [PATCHv3 1/2] mm/memblock: extend the limit inferior of bottom-up
 after parsing hotplug attr
To: Baoquan He <bhe@redhat.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>, linux-acpi@vger.kernel.org, linux-mm@kvack.org, 
	kexec@lists.infradead.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Michal Hocko <mhocko@suse.com>, Jonathan Corbet <corbet@lwn.net>, 
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Nicholas Piggin <npiggin@gmail.com>, 
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Daniel Vacek <neelx@redhat.com>, 
	Mathieu Malaterre <malat@debian.org>, Stefan Agner <stefan@agner.ch>, Dave Young <dyoung@redhat.com>, 
	yinghai@kernel.org, vgoyal@redhat.com, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190104055946.8c-9kjFSnkrZdYNNiPCmka6siKz6vS7dFTo0XgEiYCk@z>

On Wed, Jan 2, 2019 at 6:18 PM Baoquan He <bhe@redhat.com> wrote:
>
> On 01/02/19 at 11:27am, Mike Rapoport wrote:
> > On Wed, Jan 02, 2019 at 02:47:34PM +0800, Pingfan Liu wrote:
> > > On Mon, Dec 31, 2018 at 4:40 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
> > > >
> > > > On Fri, Dec 28, 2018 at 11:00:01AM +0800, Pingfan Liu wrote:
> > > > > The bottom-up allocation style is introduced to cope with movable_node,
> > > > > where the limit inferior of allocation starts from kernel's end, due to
> > > > > lack of knowledge of memory hotplug info at this early time. But if later,
> > > > > hotplug info has been got, the limit inferior can be extend to 0.
> > > > > 'kexec -c' prefers to reuse this style to alloc mem at lower address,
> > > > > since if the reserved region is beyond 4G, then it requires extra mem
> > > > > (default is 16M) for swiotlb.
> > > >
> > > > I fail to understand why the availability of memory hotplug information
> > > > would allow to extend the lower limit of bottom-up memblock allocations
> > > > below the kernel. The memory in the physical range [0, kernel_start) can be
> > > > allocated as soon as the kernel memory is reserved.
> > > >
> > > Yes, the  [0, kernel_start) can be allocated at this time by some func
> > > e.g. memblock_reserve(). But there is trick. For the func like
> > > memblock_find_in_range(), this is hotplug attr checking ,,it will
> > > check the hotmovable attr in __next_mem_range()
> > > {
> > > if (movable_node_is_enabled() && memblock_is_hotpluggable(m))
> > > continue
> > > }.  So the movable memory can be safely skipped.
> >
> > I still don't see the connection between allocating memory below
> > kernel_start and the hotplug info.
> >
> > The check for 'end > kernel_end' in
> >
> >       if (memblock_bottom_up() && end > kernel_end)
> >
> > does not protect against allocation in a hotplugable area.
> > If memblock_find_in_range() is called before hotplug info is parsed it can
> > return a range in a hotplugable area.
> >
> > The point I'd like to clarify is why allocating memory in the range [0,
> > kernel_start) cannot be done before hotplug info is available and why it is
> > safe to allocate that memory afterwards?
>
> Well, I think that's because we have KASLR. Before KASLR was introdueced,
> kernel is put at a low and fixed physical address. Allocating memblock
> bottom-up after kernel can make sure those kernel data is in the same node
> as kernel text itself before SRAT parsed. While [0, kernel_start) is a
> very small range, e.g on x86, it was 16 MB, which is very possibly used
> up.
>
> But now, with KASLR enabled by default, this bottom-up after kernel text
> allocation has potential issue. E.g we have node0 (including normal zone),
> node1(including movable zone), if KASLR put kernel at top of node0, the
> next memblock allocation before SRAT parsed will stamp into movable zone
> of node1, hotplug doesn't work well any more consequently. I had
> considered this issue previously, but haven't thought of a way to fix
> it.
>
> While it's not related to this patch. About this patchset, I didn't
> check it carefully in v2 post, and acked it. In fact the current way is
> not good, Pingfan should call __memblock_find_range_bottom_up() directly
> for crashkernel reserving. Reasons are:

Good suggestion, thanks. I will send out V4.

Regards,
Pingfan
> 1)SRAT parsing is done, system restore to take top-down way to do
> memblock allocat.
> 2)we do need to find range bottom-up if user specify crashkernel=xxM
> (without a explicit base address).
>
> Thanks
> Baoquan
>
> >
> > > Thanks for your kindly review.
> > >
> > > Regards,
> > > Pingfan
> > >
> > > > The extents of the memory node hosting the kernel image can be used to
> > > > limit memblok allocations from that particular node, even in top-down mode.
> > > >
> > > > > Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
> > > > > Cc: Tang Chen <tangchen@cn.fujitsu.com>
> > > > > Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> > > > > Cc: Len Brown <lenb@kernel.org>
> > > > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > > > Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > > > > Cc: Michal Hocko <mhocko@suse.com>
> > > > > Cc: Jonathan Corbet <corbet@lwn.net>
> > > > > Cc: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
> > > > > Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
> > > > > Cc: Nicholas Piggin <npiggin@gmail.com>
> > > > > Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > > > > Cc: Daniel Vacek <neelx@redhat.com>
> > > > > Cc: Mathieu Malaterre <malat@debian.org>
> > > > > Cc: Stefan Agner <stefan@agner.ch>
> > > > > Cc: Dave Young <dyoung@redhat.com>
> > > > > Cc: Baoquan He <bhe@redhat.com>
> > > > > Cc: yinghai@kernel.org,
> > > > > Cc: vgoyal@redhat.com
> > > > > Cc: linux-kernel@vger.kernel.org
> > > > > ---
> > > > >  drivers/acpi/numa.c      |  4 ++++
> > > > >  include/linux/memblock.h |  1 +
> > > > >  mm/memblock.c            | 58 +++++++++++++++++++++++++++++-------------------
> > > > >  3 files changed, 40 insertions(+), 23 deletions(-)
> > > > >
> > > > > diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
> > > > > index 2746994..3eea4e4 100644
> > > > > --- a/drivers/acpi/numa.c
> > > > > +++ b/drivers/acpi/numa.c
> > > > > @@ -462,6 +462,10 @@ int __init acpi_numa_init(void)
> > > > >
> > > > >               cnt = acpi_table_parse_srat(ACPI_SRAT_TYPE_MEMORY_AFFINITY,
> > > > >                                           acpi_parse_memory_affinity, 0);
> > > > > +
> > > > > +#if defined(CONFIG_X86) || defined(CONFIG_ARM64)
> > > > > +             mark_mem_hotplug_parsed();
> > > > > +#endif
> > > > >       }
> > > > >
> > > > >       /* SLIT: System Locality Information Table */
> > > > > diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> > > > > index aee299a..d89ed9e 100644
> > > > > --- a/include/linux/memblock.h
> > > > > +++ b/include/linux/memblock.h
> > > > > @@ -125,6 +125,7 @@ int memblock_reserve(phys_addr_t base, phys_addr_t size);
> > > > >  void memblock_trim_memory(phys_addr_t align);
> > > > >  bool memblock_overlaps_region(struct memblock_type *type,
> > > > >                             phys_addr_t base, phys_addr_t size);
> > > > > +void mark_mem_hotplug_parsed(void);
> > > > >  int memblock_mark_hotplug(phys_addr_t base, phys_addr_t size);
> > > > >  int memblock_clear_hotplug(phys_addr_t base, phys_addr_t size);
> > > > >  int memblock_mark_mirror(phys_addr_t base, phys_addr_t size);
> > > > > diff --git a/mm/memblock.c b/mm/memblock.c
> > > > > index 81ae63c..a3f5e46 100644
> > > > > --- a/mm/memblock.c
> > > > > +++ b/mm/memblock.c
> > > > > @@ -231,6 +231,12 @@ __memblock_find_range_top_down(phys_addr_t start, phys_addr_t end,
> > > > >       return 0;
> > > > >  }
> > > > >
> > > > > +static bool mem_hotmovable_parsed __initdata_memblock;
> > > > > +void __init_memblock mark_mem_hotplug_parsed(void)
> > > > > +{
> > > > > +     mem_hotmovable_parsed = true;
> > > > > +}
> > > > > +
> > > > >  /**
> > > > >   * memblock_find_in_range_node - find free area in given range and node
> > > > >   * @size: size of free area to find
> > > > > @@ -259,7 +265,7 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t size,
> > > > >                                       phys_addr_t end, int nid,
> > > > >                                       enum memblock_flags flags)
> > > > >  {
> > > > > -     phys_addr_t kernel_end, ret;
> > > > > +     phys_addr_t kernel_end, ret = 0;
> > > > >
> > > > >       /* pump up @end */
> > > > >       if (end == MEMBLOCK_ALLOC_ACCESSIBLE)
> > > > > @@ -270,34 +276,40 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t size,
> > > > >       end = max(start, end);
> > > > >       kernel_end = __pa_symbol(_end);
> > > > >
> > > > > -     /*
> > > > > -      * try bottom-up allocation only when bottom-up mode
> > > > > -      * is set and @end is above the kernel image.
> > > > > -      */
> > > > > -     if (memblock_bottom_up() && end > kernel_end) {
> > > > > -             phys_addr_t bottom_up_start;
> > > > > +     if (memblock_bottom_up()) {
> > > > > +             phys_addr_t bottom_up_start = start;
> > > > >
> > > > > -             /* make sure we will allocate above the kernel */
> > > > > -             bottom_up_start = max(start, kernel_end);
> > > > > -
> > > > > -             /* ok, try bottom-up allocation first */
> > > > > -             ret = __memblock_find_range_bottom_up(bottom_up_start, end,
> > > > > -                                                   size, align, nid, flags);
> > > > > -             if (ret)
> > > > > +             if (mem_hotmovable_parsed) {
> > > > > +                     ret = __memblock_find_range_bottom_up(
> > > > > +                             bottom_up_start, end, size, align, nid,
> > > > > +                             flags);
> > > > >                       return ret;
> > > > >
> > > > >               /*
> > > > > -              * we always limit bottom-up allocation above the kernel,
> > > > > -              * but top-down allocation doesn't have the limit, so
> > > > > -              * retrying top-down allocation may succeed when bottom-up
> > > > > -              * allocation failed.
> > > > > -              *
> > > > > -              * bottom-up allocation is expected to be fail very rarely,
> > > > > -              * so we use WARN_ONCE() here to see the stack trace if
> > > > > -              * fail happens.
> > > > > +              * if mem hotplug info is not parsed yet, try bottom-up
> > > > > +              * allocation with @end above the kernel image.
> > > > >                */
> > > > > -             WARN_ONCE(IS_ENABLED(CONFIG_MEMORY_HOTREMOVE),
> > > > > +             } else if (!mem_hotmovable_parsed && end > kernel_end) {
> > > > > +                     /* make sure we will allocate above the kernel */
> > > > > +                     bottom_up_start = max(start, kernel_end);
> > > > > +                     ret = __memblock_find_range_bottom_up(
> > > > > +                             bottom_up_start, end, size, align, nid,
> > > > > +                             flags);
> > > > > +                     if (ret)
> > > > > +                             return ret;
> > > > > +                     /*
> > > > > +                      * we always limit bottom-up allocation above the
> > > > > +                      * kernel, but top-down allocation doesn't have
> > > > > +                      * the limit, so retrying top-down allocation may
> > > > > +                      * succeed when bottom-up allocation failed.
> > > > > +                      *
> > > > > +                      * bottom-up allocation is expected to be fail
> > > > > +                      * very rarely, so we use WARN_ONCE() here to see
> > > > > +                      * the stack trace if fail happens.
> > > > > +                      */
> > > > > +                     WARN_ONCE(IS_ENABLED(CONFIG_MEMORY_HOTREMOVE),
> > > > >                         "memblock: bottom-up allocation failed, memory hotremove may be affected\n");
> > > > > +             }
> > > > >       }
> > > > >
> > > > >       return __memblock_find_range_top_down(start, end, size, align, nid,
> > > > > --
> > > > > 2.7.4
> > > > >
> > > >
> > > > --
> > > > Sincerely yours,
> > > > Mike.
> > > >
> > >
> >
> > --
> > Sincerely yours,
> > Mike.
> >

