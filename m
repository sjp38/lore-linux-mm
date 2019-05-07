Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA794C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 19:04:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF54720578
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 19:04:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="X2+ZQdZ3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF54720578
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 49ADD6B0003; Tue,  7 May 2019 15:04:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 44AA16B0006; Tue,  7 May 2019 15:04:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 313106B0007; Tue,  7 May 2019 15:04:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0405D6B0003
	for <linux-mm@kvack.org>; Tue,  7 May 2019 15:04:41 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id h13so9735232otq.2
        for <linux-mm@kvack.org>; Tue, 07 May 2019 12:04:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=LNbESQrObZxBB/LE+wWHLIjxgekRF8A+W3warHaag5A=;
        b=oUyCiSY6R8GGg+3uP4iD6DpkRj361UmiZi8IefrBxCsXbg0kxxaTHIcLOzUyif7MBX
         fU14bZui4gW51ikfavyu4HvKUcVhjE/AEwTmmrdYSPbcxfCNU3HjBwrF7O/AZ1fIqHOW
         UTiJo4cjTnXTuHkj4mobZdWMJH1MdSFM8KbSa+E+4g5efho+G4gvL9bOX0qYxi+BDnPG
         KviWwLX2GBKPmUxD5MLLf6XovPuuQEbkpEkHRiz5OHS2zoa/cz4hMYSR4mSKi3vi2WZ3
         4c6vsnPt4yzWpJ6ppu3t/UxajFuMswhJuK5gCwWLT9w40XpjY+p5ZpGxfFwtc7BELlq0
         idGA==
X-Gm-Message-State: APjAAAW+NJHw3c2Byvic0/C5sC13Q/+o+MQ8qejHdfnw2R5eCZXXJxZo
	/5KnrNZmFL7vPWa2bs9d7GBAPeqSl6F5I+PMhpgjzIIKjryujpyz48sIo7nOCrQzzu4HZnDC6ey
	bNOPfa9gw+uhwdlFI2zj2l65XavnnaNgXdFhRFWawXm1y14YA82JOZimUcvNGU7nLXQ==
X-Received: by 2002:a05:6830:1cb:: with SMTP id r11mr363138ota.344.1557255880673;
        Tue, 07 May 2019 12:04:40 -0700 (PDT)
X-Received: by 2002:a05:6830:1cb:: with SMTP id r11mr363075ota.344.1557255879780;
        Tue, 07 May 2019 12:04:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557255879; cv=none;
        d=google.com; s=arc-20160816;
        b=JHwYPfLSdmRIBWFnZ/pnrYXTIobRQQzPflqfYhoXsbTgJeS9o57QlLqVX/wmbG/JKu
         j6ign2FtPWWtgSXWo+xbecqs5J7XQm/Y+Vq3IZ1/0JQInWh3btRdSa/UDeyn0VFKQFOE
         ADcCuf7usGo4LVtsTlEDxqvW3U2JOe0mb6Hu5DDOtH3D9k8A4RurQox5as56uQSCWW+z
         eXSOEwTI83osm1ze/3VNtGJv/hMrtHi/X/sud7iHHDE1Wkd6kxBcXFBbzmls1+Qz1YKN
         QElARwzijDy6FpnkRWLEj9r2QQQbDvea4OWjEJKEqx/pfdid2EiwowWMPS1OWpX68Rvv
         36mg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=LNbESQrObZxBB/LE+wWHLIjxgekRF8A+W3warHaag5A=;
        b=ICj179/12GiuBGST1DkDfxvcl5E/otF5OrjWXbXXcTq4ak5YULzMYRPe+CJ+ni+6ti
         Cz6ulUFAf2YUqUBoIk8QHKZFffua+3AQifgXEbuMmDiRWqB3dDI9L2ITCM41J9+gHHg8
         U2Uz/td4XQA+ulTCCwDm9Xs0Z+IuR5sE9+a8SE96W74+bh2ZYMPGWW0/YYTm4fwrifgs
         gTood+7wR4w/jBwZSGZMLbnXgoxHSXddwMZZMuubWbUcBpgtLutC/4WIa8MA9EX3TaqU
         /6U144danabVWJxUzNOLKQlg3S9sBs+OJIxGgFThUb6Ajus+e1hH0orNJFdulsfbtUeh
         ni7g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=X2+ZQdZ3;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l23sor6439898otn.124.2019.05.07.12.04.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 12:04:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=X2+ZQdZ3;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=LNbESQrObZxBB/LE+wWHLIjxgekRF8A+W3warHaag5A=;
        b=X2+ZQdZ3QZjS6d5t5fCH13GepkH6SjaBJAihzeJ4GXjAXyRZSRTGPpBRLypEAsjGIW
         cm7WMvIKqpUHcSWqUhAr15RzuVhsm9xYIgVOzdG6jAuLjuYexnOs5AT+7PvBNweZTrhS
         XJb86bUc/0uEatfh0rES11f0xEgfRlp6FYf7Ve/cMp6EGhSSST6O5ilOXRP6cikBWOSN
         9TpRFPw3ofec2FWb107b0EzNCm6ELKgNFaaPSlE16j08So405N7h8iDEKKbEv/MGWkdC
         BO21f77OIMvR2dKsAyl5SpSrRWJ18aMWN5G9g8VLqySe7ZytZ6AbMkSrq4jv7t/OUdIa
         hgBg==
X-Google-Smtp-Source: APXvYqwy1LirnerPqPYkGArLlzfXeDDofdcMt5S845Oc+1dy47VZIK6kvPHjm+20DQyjEymtJKZaVdZYEtVIUkJ7mqQ=
X-Received: by 2002:a9d:19ed:: with SMTP id k100mr24122234otk.214.1557255879316;
 Tue, 07 May 2019 12:04:39 -0700 (PDT)
MIME-Version: 1.0
References: <20190507183804.5512-1-david@redhat.com>
In-Reply-To: <20190507183804.5512-1-david@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 7 May 2019 12:04:28 -0700
Message-ID: <CAPcyv4gxwhsiZ8Hjm4cNbjmLXV2m4s=t14ZoH0uf8AADP2nOtA@mail.gmail.com>
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

On Tue, May 7, 2019 at 11:38 AM David Hildenbrand <david@redhat.com> wrote:
>
> We only want memory block devices for memory to be onlined/offlined
> (add/remove from the buddy). This is required so user space can
> online/offline memory and kdump gets notified about newly onlined memory.
>
> Only such memory has the requirement of having to span whole memory blocks.
> Let's factor out creation/removal of memory block devices. This helps
> to further cleanup arch_add_memory/arch_remove_memory() and to make
> implementation of new features easier. E.g. supplying a driver for
> memory block devices becomes way easier (so user space is able to
> distinguish different types of added memory to properly online it).
>
> Patch 1 makes sure the memory block size granularity is always respected.
> Patch 2 implements arch_remove_memory() on s390x. Patch 3 prepares
> arch_remove_memory() to be also called without CONFIG_MEMORY_HOTREMOVE.
> Patch 4,5 and 6 factor out creation/removal of memory block devices.
> Patch 7 gets rid of some unlikely errors that could have happened, not
> removing links between memory block devices and nodes, previously brought
> up by Oscar.
>
> Did a quick sanity test with DIMM plug/unplug, making sure all devices
> and sysfs links properly get added/removed. Compile tested on s390x and
> x86-64.
>
> Based on git://git.cmpxchg.org/linux-mmots.git
>
> Next refactoring on my list will be making sure that remove_memory()
> will never deal with zones / access "struct pages". Any kind of zone
> handling will have to be done when offlining system memory / before
> removing device memory. I am thinking about remove_pfn_range_from_zone()",
> du undo everything "move_pfn_range_to_zone()" did.
>
> v1 -> v2:
> - s390x/mm: Implement arch_remove_memory()
> -- remove mapping after "__remove_pages"
>
>
> David Hildenbrand (8):
>   mm/memory_hotplug: Simplify and fix check_hotplug_memory_range()
>   s390x/mm: Implement arch_remove_memory()
>   mm/memory_hotplug: arch_remove_memory() and __remove_pages() with
>     CONFIG_MEMORY_HOTPLUG
>   mm/memory_hotplug: Create memory block devices after arch_add_memory()
>   mm/memory_hotplug: Drop MHP_MEMBLOCK_API

So at a minimum we need a bit of patch staging guidance because this
obviously collides with the subsection bits that are built on top of
the existence of MHP_MEMBLOCK_API. What trigger do you envision as a
replacement that arch_add_memory() use to determine that subsection
operations should be disallowed?

