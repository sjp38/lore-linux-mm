Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B078C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 20:37:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E540320656
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 20:37:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="YRealVS9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E540320656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D5AD6B0003; Tue,  7 May 2019 16:37:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 75FD56B0006; Tue,  7 May 2019 16:37:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5FE406B0007; Tue,  7 May 2019 16:37:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2C3566B0003
	for <linux-mm@kvack.org>; Tue,  7 May 2019 16:37:09 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id 72so835530otv.23
        for <linux-mm@kvack.org>; Tue, 07 May 2019 13:37:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=z5b4zkXTkfpWqCiSB1RgkAhgkwdMX71/E3FP2qDv8Ro=;
        b=OvPGqBV3QkqgpQyjVGbd47L46Z2PQ6JANuwIHungkZsCXVQVzjT/NkP0FQ0TD844PT
         W+FoNpfdTsj7OintioLYxA2yx7ZsKSbSDyKgCKnTNu6KSqBqdwklqTw8IxiCAdEmtcdG
         HYsPHIPr6+2az5Wy8boq6qh+3aJkqZq69xMu2uzhktQWbfcqPVIQd5TYWYw4VZfmbfzs
         wIDSzbuZSG8kzIgwXlhu7Hp/ZxabfVGafOYIsL5TvnpkhXn4awa+ekht2KEjNkRZO2tI
         Mtdc5dH2bpH4V84XVlbJ9x+Ce4tkykgfyVPMDi8a2QnTgZpUt6SQbOMmLpiILCUeaBL5
         Ev9A==
X-Gm-Message-State: APjAAAVABD1eC3SHrBo2oDZj/F0qrQqHeaR8Izl5dDcUU62oPUIpqBFN
	Yf0Fy247ZYkP3NTRS+uVn5lzetrZsRWeu1p+GqvOaAecNSlBTacGm39axA2KagcQJD1ATPcbWP8
	8YDDzwTH6igCPgS15udFBwd3dfR9LQ451rtZqSAgINY2jyaj0ALRgyrG+kToNjvNRMg==
X-Received: by 2002:a9d:dca:: with SMTP id 68mr3846758ots.119.1557261428795;
        Tue, 07 May 2019 13:37:08 -0700 (PDT)
X-Received: by 2002:a9d:dca:: with SMTP id 68mr3846713ots.119.1557261427800;
        Tue, 07 May 2019 13:37:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557261427; cv=none;
        d=google.com; s=arc-20160816;
        b=aHsuWQMwgrOGjy5oMpCxpRacLdnnexcJBQm7i/JVAdS/HTG64i+q5Bzobj1+jcKiE9
         QSfvTY3vHbI4lVmzvALVg9ELDJvLipCUwTGTho2LtWWQTtiBfLUXdVGy+4lVnpTt+UZu
         oeHoHPMzy0li1mB1QccOcBF6YbkcONPooLcaPh8wBjmjuU1UuWjVDik51meGJskS7z3w
         qrXeqUDeNN9b13oA00NGBaZ1PijeCImn/Jr2uLMn4nDYoppyCabwPueZ1wdcv2T83RTK
         FiIprdpxkezntHS1vp0vTIdhZb2VDv9ZrXgDzsnVl5zrj5MahOFgiY6elO99zLtW1Wyb
         4mYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=z5b4zkXTkfpWqCiSB1RgkAhgkwdMX71/E3FP2qDv8Ro=;
        b=eZgnElW8YQdsVVFaVPZCqh9hknK5wTa7Th1DnzjaEqfw6a9aqVnl7WqWW8KAWqJbxC
         tyYaqfV3FVomB7qoExuvmWQ3TAaIjTYUdiBHjyGAycMXPEqgsJHm5ailcekuHw4l4Fdx
         v7NMgKRDaK9qTtygD1gjotSPIsonckPEdNO7Gs25F5yClfTRmb+MT/4sYewylvHYWV46
         weGisevK01GHAYR+anl8xvy7zdODYoY83MyI2wAZ4pN/XgzpUGpgAvaGSuH6rCBcuj6l
         ksu1d04fVlL7QzptXNij7AfZXPaVFoCVdLr5mG4VokBQfC6EFq0KsueZ5oLxVUxBWvNM
         tXtA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=YRealVS9;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j6sor6702061otl.108.2019.05.07.13.37.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 13:37:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=YRealVS9;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=z5b4zkXTkfpWqCiSB1RgkAhgkwdMX71/E3FP2qDv8Ro=;
        b=YRealVS9Md1Jy2ldrqKzh/vua5vtH9R9hKTSLWZ5p948y/VVUigYm8/fTzWVYdJrLS
         zqbQsSvYrj1RhZQpSlxgTdTrdH2Zcj4h5FdzSiA30CaaWUY22QyfYSFRJFEfdwBwmNxX
         jmWAQGnHoTO58kTw9bJG0CS77dWEknwuUgQ10RKpBtGZdJBxzTZpiaPA/BXwcDLgRB0Y
         ypoJ4JuiXAGKuD425JMucEXhpY+iddsqzh7s66QEyJ/04j7Yz7eT9fT03b5NmrcDmE0I
         A1CPUFRjoysFvAT+gSsrGulOZ9FWi/FxEiGsahRZRiFZVYln05+etYoXT4LzNQxNj+Cy
         QW6g==
X-Google-Smtp-Source: APXvYqxO7g7RJJ/ttlGXNE6d39oOgVmNZnUt9QkVRoOGG+esA9T1LY329N+RzaKz6GerbpavAiuJgB9UwuUQhGczlN4=
X-Received: by 2002:a9d:19ed:: with SMTP id k100mr24473505otk.214.1557261427346;
 Tue, 07 May 2019 13:37:07 -0700 (PDT)
MIME-Version: 1.0
References: <20190507183804.5512-1-david@redhat.com> <CAPcyv4gxwhsiZ8Hjm4cNbjmLXV2m4s=t14ZoH0uf8AADP2nOtA@mail.gmail.com>
 <6f69e615-2b4a-ff31-5d2a-e1711c564f9b@redhat.com> <ad971f57-5f09-c056-beef-6a7b63311106@redhat.com>
In-Reply-To: <ad971f57-5f09-c056-beef-6a7b63311106@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 7 May 2019 13:36:55 -0700
Message-ID: <CAPcyv4gvwXDP7ZVBpxtEZJSNiHC_zoHEy1HzUk3FgpS5O5s1Yg@mail.gmail.com>
Subject: Re: [PATCH v2 0/8] mm/memory_hotplug: Factor out memory block device handling
To: David Hildenbrand <david@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, 
	Linux-sh <linux-sh@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Alex Deucher <alexander.deucher@amd.com>, Andrew Banman <andrew.banman@hpe.com>, 
	Andy Lutomirski <luto@kernel.org>, Arun KS <arunks@codeaurora.org>, Baoquan He <bhe@redhat.com>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Borislav Petkov <bp@alien8.de>, 
	Christophe Leroy <christophe.leroy@c-s.fr>, Chris Wilson <chris@chris-wilson.co.uk>, 
	Dave Hansen <dave.hansen@linux.intel.com>, "David S. Miller" <davem@davemloft.net>, 
	Fenghua Yu <fenghua.yu@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@zytor.com>, 
	Ingo Molnar <mingo@kernel.org>, Ingo Molnar <mingo@redhat.com>, 
	Jonathan Cameron <Jonathan.Cameron@huawei.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Logan Gunthorpe <logang@deltatee.com>, 
	Mark Brown <broonie@kernel.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, Mathieu Malaterre <malat@debian.org>, 
	Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.ibm.com>, 
	Mike Rapoport <rppt@linux.vnet.ibm.com>, "mike.travis@hpe.com" <mike.travis@hpe.com>, 
	Nicholas Piggin <npiggin@gmail.com>, Oscar Salvador <osalvador@suse.com>, 
	Oscar Salvador <osalvador@suse.de>, Paul Mackerras <paulus@samba.org>, 
	Pavel Tatashin <pasha.tatashin@soleen.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, 
	Peter Zijlstra <peterz@infradead.org>, Qian Cai <cai@lca.pw>, 
	"Rafael J. Wysocki" <rafael@kernel.org>, Rich Felker <dalias@libc.org>, Rob Herring <robh@kernel.org>, 
	Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, 
	Vasily Gorbik <gor@linux.ibm.com>, Wei Yang <richard.weiyang@gmail.com>, 
	Wei Yang <richardw.yang@linux.intel.com>, Yoshinori Sato <ysato@users.sourceforge.jp>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 7, 2019 at 12:38 PM David Hildenbrand <david@redhat.com> wrote:
>
> On 07.05.19 21:21, David Hildenbrand wrote:
> > On 07.05.19 21:04, Dan Williams wrote:
> >> On Tue, May 7, 2019 at 11:38 AM David Hildenbrand <david@redhat.com> wrote:
> >>>
> >>> We only want memory block devices for memory to be onlined/offlined
> >>> (add/remove from the buddy). This is required so user space can
> >>> online/offline memory and kdump gets notified about newly onlined memory.
> >>>
> >>> Only such memory has the requirement of having to span whole memory blocks.
> >>> Let's factor out creation/removal of memory block devices. This helps
> >>> to further cleanup arch_add_memory/arch_remove_memory() and to make
> >>> implementation of new features easier. E.g. supplying a driver for
> >>> memory block devices becomes way easier (so user space is able to
> >>> distinguish different types of added memory to properly online it).
> >>>
> >>> Patch 1 makes sure the memory block size granularity is always respected.
> >>> Patch 2 implements arch_remove_memory() on s390x. Patch 3 prepares
> >>> arch_remove_memory() to be also called without CONFIG_MEMORY_HOTREMOVE.
> >>> Patch 4,5 and 6 factor out creation/removal of memory block devices.
> >>> Patch 7 gets rid of some unlikely errors that could have happened, not
> >>> removing links between memory block devices and nodes, previously brought
> >>> up by Oscar.
> >>>
> >>> Did a quick sanity test with DIMM plug/unplug, making sure all devices
> >>> and sysfs links properly get added/removed. Compile tested on s390x and
> >>> x86-64.
> >>>
> >>> Based on git://git.cmpxchg.org/linux-mmots.git
> >>>
> >>> Next refactoring on my list will be making sure that remove_memory()
> >>> will never deal with zones / access "struct pages". Any kind of zone
> >>> handling will have to be done when offlining system memory / before
> >>> removing device memory. I am thinking about remove_pfn_range_from_zone()",
> >>> du undo everything "move_pfn_range_to_zone()" did.
> >>>
> >>> v1 -> v2:
> >>> - s390x/mm: Implement arch_remove_memory()
> >>> -- remove mapping after "__remove_pages"
> >>>
> >>>
> >>> David Hildenbrand (8):
> >>>   mm/memory_hotplug: Simplify and fix check_hotplug_memory_range()
> >>>   s390x/mm: Implement arch_remove_memory()
> >>>   mm/memory_hotplug: arch_remove_memory() and __remove_pages() with
> >>>     CONFIG_MEMORY_HOTPLUG
> >>>   mm/memory_hotplug: Create memory block devices after arch_add_memory()
> >>>   mm/memory_hotplug: Drop MHP_MEMBLOCK_API
> >>
> >> So at a minimum we need a bit of patch staging guidance because this
> >> obviously collides with the subsection bits that are built on top of
> >> the existence of MHP_MEMBLOCK_API. What trigger do you envision as a
> >> replacement that arch_add_memory() use to determine that subsection
> >> operations should be disallowed?
> >>
> >
> > Looks like we now have time to sort it out :)
> >
> >
> > Looking at your series
> >
> > [PATCH v8 08/12] mm/sparsemem: Prepare for sub-section ranges
> >
> > is the "single" effectively place using MHP_MEMBLOCK_API, namely
> > "subsection_check()". Used when adding/removing memory.
> >
> >
> > +static int subsection_check(unsigned long pfn, unsigned long nr_pages,
> > +             unsigned long flags, const char *reason)
> > +{
> > +     /*
> > +      * Only allow partial section hotplug for !memblock ranges,
> > +      * since register_new_memory() requires section alignment, and
> > +      * CONFIG_SPARSEMEM_VMEMMAP=n requires sections to be fully
> > +      * populated.
> > +      */
> > +     if ((!IS_ENABLED(CONFIG_SPARSEMEM_VMEMMAP)
> > +                             || (flags & MHP_MEMBLOCK_API))
> > +                     && ((pfn & ~PAGE_SECTION_MASK)
> > +                             || (nr_pages & ~PAGE_SECTION_MASK))) {
> > +             WARN(1, "Sub-section hot-%s incompatible with %s\n", reason,
> > +                             (flags & MHP_MEMBLOCK_API)
> > +                             ? "memblock api" : "!CONFIG_SPARSEMEM_VMEMMAP");
> > +             return -EINVAL;
> > +     }
> > +     return 0;
> >  }
> >
> >
> > (flags & MHP_MEMBLOCK_API)) && ((pfn & ~PAGE_SECTION_MASK) || (nr_pages
> > & ~PAGE_SECTION_MASK)))
> >
> > sounds like something the caller (add_memory()) always has to take care
> > of. No need to check. The one imposing this restriction is the only caller.
> >
> > In my opinion, that check/function can go completely.
> >
> > Am I missing something / missing another user?
> >
>
> In other word, this series moves the restriction out of
> arch_add_memory() and therefore you don't need subsection_check() at all
> anymore. At least if I am not missing something :)

Ah, ok. Only direct arch_add_memory() users need to be worried about
subsection hotplug and the add_memory_resource() + __remove_memory()
paths are already protected by check_hotplug_memory_range(). Ok, I can
get on board with the removal.

Let me go ahead and review this series so Andrew can get it pulled in
and I can rebase.

