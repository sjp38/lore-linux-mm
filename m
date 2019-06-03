Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F084EC04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 21:21:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A259826B27
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 21:21:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XQ/b11C8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A259826B27
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 334616B0269; Mon,  3 Jun 2019 17:21:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E4426B026A; Mon,  3 Jun 2019 17:21:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1AC6E6B026C; Mon,  3 Jun 2019 17:21:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id BC6C26B0269
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 17:21:49 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c1so29232056edi.20
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 14:21:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mDmSeoJUhGrEtos9TXtgY/7zbEqsIvl9K5n7SoOuM0Q=;
        b=aPHCu83G0f35Mmba6DAIBxasI6a/+Ij/8ms5mZ/C91+seJrItW1IroTZHbQnVX6T4r
         x01PDG3DNjOBWyZc9Mmh3vXPwvwQ27H6s71JqUdQxwYmlvQSTK1uDMtesvx+pX3WT7SK
         4nQif/SmOYSHwEu+BCi2Z/bsBJ24pCSWxmEEx0uRi7KPZmPe1sSx36rcO0kFEhpRwFhu
         fz0VPcQunSdYz7iM6XO3RMuXuvZ9X8NfhfO5HoS/QHKQLsJEZldlP/b+ay4jTy1cnKAF
         QliZL4ISF2VLDjH4QPo4sWsIFSyirEzpywG1Acku7da1CT5CK5BarMRi1r6fgandlT+K
         1lbg==
X-Gm-Message-State: APjAAAUv8GWHMjoJTrobMSX4H6txFiLudPwidhdLZBLyfobsR/go9uST
	L+MQ7etXinmCCDjvr1VfEI6AN3BEnCUNH6IGLi8F1qf8idGJ5R+uh3/xFaEpAb2UGGBqRWCXF38
	G9dJZ8Ixgv6GMo0wPd+i2fYkWGOwcDT/lhu/fsMAMswJFTKWE8UrPSskIAA28Xb5Zyg==
X-Received: by 2002:a17:906:4892:: with SMTP id v18mr12867604ejq.299.1559596909196;
        Mon, 03 Jun 2019 14:21:49 -0700 (PDT)
X-Received: by 2002:a17:906:4892:: with SMTP id v18mr12867559ejq.299.1559596908339;
        Mon, 03 Jun 2019 14:21:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559596908; cv=none;
        d=google.com; s=arc-20160816;
        b=ntrxcl5luxGn08LIrZ/aEnNf7IlspA34NqeckybUWKyUb+8h6tmUpSZaE7whK0AFuJ
         3AGIxAw5+6GX5tqjC4c+8lc+2msQ2yb73sE8+onFIBwzaLf/xZ4b7b0pPZlLwGdg+i/0
         HI4sdDb6LlnUMb1RSL2NThsWgTcMTOfNf2YQhuFCQ4z3PXMD1rWzs4knfVjdW+atja5B
         BUNObSWVYv3matAJMovZDAzi79WoiG4Sl9O2YVqZAyiaXyGsury0aRKJbMHXdErKvzRj
         GxjlXS2/BhvBYDvFi5eqagrJfmx9mszJWanx5Qt8zFnVi3oqItJE2YDsziL9Q4OPBMqs
         ytPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date:dkim-signature;
        bh=mDmSeoJUhGrEtos9TXtgY/7zbEqsIvl9K5n7SoOuM0Q=;
        b=Sh9JOEzZeMxfsX29081vX6DhbLJzQjZHoWEB3EFHv3np1XKBVVOtWDsE9VoWgro0ZL
         i39hSgI+xiaNqzHKtEc6/zccbnQLESJpFPIMhSVE8WyTfC5PSZLxsrerxVUkHZimAHOs
         sGQws4WMJVU6dsyRKdfqxw0B84I9dC7nYHwU8NuJaccFcLTBqNDWm159+CEMnjyWvwEc
         5UitgPKnfbpMt0hi+orcdItseeRKs7fzyaCHhGPmcpoYDvyom18tHZvr9ZpuMhDZpkq4
         zRti7FBww80WjRY2FS1SVqUq9La9bj/UsRNBgrEzaMP/Aa0pxETls5AVPOPIL7ItCc8r
         N1Cw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="XQ/b11C8";
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c10sor4965417ejd.6.2019.06.03.14.21.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 14:21:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="XQ/b11C8";
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=mDmSeoJUhGrEtos9TXtgY/7zbEqsIvl9K5n7SoOuM0Q=;
        b=XQ/b11C8narXjTlhkZ1MB7tWYfM3tn0gmctbAqj3Rg65oTPOPd5SHeIFfV4+pTgR06
         H2yUQs+GBXTI5/pQ11GhtJSYOg13gCScGhp5Uw4kkyuuOGYt2F8pO4q/wP7TqotREBPc
         91e2hzzlvI3jTc6Z7b/WV/1ytW/7sSbPDcIpe9KhAfWyMGiA57S7aTr5cRiMnKok7aog
         vWuu1tjLrXDviSm0kHoQBVanBMljxHAaqcY7ozxKezrnJVSUuVb4Q6bWbsKWwYjxxekA
         3shYVDSVWHN9XLsu1dh1Z3t+e/B6spVRthobIhqAdP0+bOyU/uJFUcEFcRXticxtZ4Ct
         /ELA==
X-Google-Smtp-Source: APXvYqyaKi12rIWxwu+9xuJ+SjF9E6cYt6eiwEWk3oV6ngFX6Zl36r7DH7SlPfRLKG6EtJguaiB+Vw==
X-Received: by 2002:a17:906:fcda:: with SMTP id qx26mr24558965ejb.92.1559596907853;
        Mon, 03 Jun 2019 14:21:47 -0700 (PDT)
Received: from localhost ([185.92.221.13])
        by smtp.gmail.com with ESMTPSA id s57sm4311051edd.54.2019.06.03.14.21.46
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 14:21:46 -0700 (PDT)
Date: Mon, 3 Jun 2019 21:21:46 +0000
From: Wei Yang <richard.weiyang@gmail.com>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>,
	Alex Deucher <alexander.deucher@amd.com>,
	Andrew Banman <andrew.banman@hpe.com>,
	Andy Lutomirski <luto@kernel.org>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arun KS <arunks@codeaurora.org>, Baoquan He <bhe@redhat.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Chris Wilson <chris@chris-wilson.co.uk>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>,
	Ingo Molnar <mingo@redhat.com>,
	Jonathan Cameron <Jonathan.Cameron@huawei.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Jun Yao <yaojun8558363@gmail.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	Mark Brown <broonie@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Mathieu Malaterre <malat@debian.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.ibm.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	"mike.travis@hpe.com" <mike.travis@hpe.com>,
	Nicholas Piggin <npiggin@gmail.com>,
	Oscar Salvador <osalvador@suse.com>,
	Oscar Salvador <osalvador@suse.de>,
	Paul Mackerras <paulus@samba.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Pavel Tatashin <pavel.tatashin@microsoft.com>,
	Peter Zijlstra <peterz@infradead.org>, Qian Cai <cai@lca.pw>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Rich Felker <dalias@libc.org>, Rob Herring <robh@kernel.org>,
	Robin Murphy <robin.murphy@arm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Tony Luck <tony.luck@intel.com>, Vasily Gorbik <gor@linux.ibm.com>,
	Wei Yang <richardw.yang@linux.intel.com>,
	Will Deacon <will.deacon@arm.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Yu Zhao <yuzhao@google.com>
Subject: Re: [PATCH v3 00/11] mm/memory_hotplug: Factor out memory block
 devicehandling
Message-ID: <20190603212146.7hdha6wrlxtkxxxr@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20190527111152.16324-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527111152.16324-1-david@redhat.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

IMHO, there is some typo.

s/devicehandling/device handling/

On Mon, May 27, 2019 at 01:11:41PM +0200, David Hildenbrand wrote:
>We only want memory block devices for memory to be onlined/offlined
>(add/remove from the buddy). This is required so user space can
>online/offline memory and kdump gets notified about newly onlined memory.
>
>Let's factor out creation/removal of memory block devices. This helps
>to further cleanup arch_add_memory/arch_remove_memory() and to make
>implementation of new features easier - especially sub-section
>memory hot add from Dan.
>
>Anshuman Khandual is currently working on arch_remove_memory(). I added
>a temporary solution via "arm64/mm: Add temporary arch_remove_memory()
>implementation", that is sufficient as a firsts tep in the context of

s/firsts tep/first step/

>this series. (we don't cleanup page tables in case anything goes
>wrong already)
>
>Did a quick sanity test with DIMM plug/unplug, making sure all devices
>and sysfs links properly get added/removed. Compile tested on s390x and
>x86-64.
>
>Based on next/master.
>
>Next refactoring on my list will be making sure that remove_memory()
>will never deal with zones / access "struct pages". Any kind of zone
>handling will have to be done when offlining system memory / before
>removing device memory. I am thinking about remove_pfn_range_from_zone()",
>du undo everything "move_pfn_range_to_zone()" did.

what is "du undo"? I may not get it.

>
>v2 -> v3:
>- Add "s390x/mm: Fail when an altmap is used for arch_add_memory()"
>- Add "arm64/mm: Add temporary arch_remove_memory() implementation"
>- Add "drivers/base/memory: Pass a block_id to init_memory_block()"
>- Various changes to "mm/memory_hotplug: Create memory block devices
>  after arch_add_memory()" and "mm/memory_hotplug: Create memory block
>  devices after arch_add_memory()" due to switching from sections to
>  block_id's.
>
>v1 -> v2:
>- s390x/mm: Implement arch_remove_memory()
>-- remove mapping after "__remove_pages"
>
>David Hildenbrand (11):
>  mm/memory_hotplug: Simplify and fix check_hotplug_memory_range()
>  s390x/mm: Fail when an altmap is used for arch_add_memory()
>  s390x/mm: Implement arch_remove_memory()
>  arm64/mm: Add temporary arch_remove_memory() implementation
>  drivers/base/memory: Pass a block_id to init_memory_block()
>  mm/memory_hotplug: Allow arch_remove_pages() without
>    CONFIG_MEMORY_HOTREMOVE
>  mm/memory_hotplug: Create memory block devices after arch_add_memory()
>  mm/memory_hotplug: Drop MHP_MEMBLOCK_API
>  mm/memory_hotplug: Remove memory block devices before
>    arch_remove_memory()
>  mm/memory_hotplug: Make unregister_memory_block_under_nodes() never
>    fail
>  mm/memory_hotplug: Remove "zone" parameter from
>    sparse_remove_one_section
>
> arch/arm64/mm/mmu.c            |  17 +++++
> arch/ia64/mm/init.c            |   2 -
> arch/powerpc/mm/mem.c          |   2 -
> arch/s390/mm/init.c            |  18 +++--
> arch/sh/mm/init.c              |   2 -
> arch/x86/mm/init_32.c          |   2 -
> arch/x86/mm/init_64.c          |   2 -
> drivers/base/memory.c          | 134 +++++++++++++++++++--------------
> drivers/base/node.c            |  27 +++----
> include/linux/memory.h         |   6 +-
> include/linux/memory_hotplug.h |  12 +--
> include/linux/node.h           |   7 +-
> mm/memory_hotplug.c            |  44 +++++------
> mm/sparse.c                    |  10 +--
> 14 files changed, 140 insertions(+), 145 deletions(-)
>
>-- 
>2.20.1

-- 
Wei Yang
Help you, Help me

