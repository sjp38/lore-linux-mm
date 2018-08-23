Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 113D96B2A8D
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 10:34:41 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id u13-v6so4755394qtb.18
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 07:34:41 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id m189-v6si3064689qkd.19.2018.08.23.07.34.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 07:34:40 -0700 (PDT)
Date: Thu, 23 Aug 2018 10:34:38 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: A crash on ARM64 in move_freepages_block due to uninitialized
 pages in reserved memory
In-Reply-To: <777276b8-9cd6-da4b-d1d9-c60f96a58122@microsoft.com>
Message-ID: <alpine.LRH.2.02.1808231017570.4129@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1808171527220.2385@file01.intranet.prod.int.rdu2.redhat.com> <20180821104418.GA16611@dhcp22.suse.cz> <e35b7c14-c7ea-412d-2763-c961b74576f3@arm.com> <alpine.LRH.2.02.1808220808050.17906@file01.intranet.prod.int.rdu2.redhat.com>
 <20180823111024.GC29735@dhcp22.suse.cz> <alpine.LRH.2.02.1808230715050.30076@file01.intranet.prod.int.rdu2.redhat.com> <20180823112359.GE29735@dhcp22.suse.cz> <777276b8-9cd6-da4b-d1d9-c60f96a58122@microsoft.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Cc: Michal Hocko <mhocko@kernel.org>, James Morse <james.morse@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>



On Thu, 23 Aug 2018, Pasha Tatashin wrote:

> On 8/23/18 7:23 AM, Michal Hocko wrote:
> > On Thu 23-08-18 07:16:34, Mikulas Patocka wrote:
> >>
> >>
> >> On Thu, 23 Aug 2018, Michal Hocko wrote:
> >>
> >>> On Thu 23-08-18 07:02:37, Mikulas Patocka wrote:
> >>> [...]
> >>>> This crash is not from -ENOENT. It crashes because page->compound_head is 
> >>>> 0xffffffffffffffff (see below).
> >>>>
> >>>> If I enable CONFIG_DEBUG_VM, I also get VM_BUG.
> >>>
> >>> This smells like the struct page is not initialized properly. How is
> >>> this memory range added? I mean is it brought up by the memory hotplug
> >>> or during the boot?
> 
> I believe it is due to uninitialized struct pages. Mikulas, could you
> please provide config file, and also the full console output.
> 
> Please make sure that you have:
> CONFIG_DEBUG_VM=y
> CONFIG_ARCH_HAS_DEBUG_VIRTUAL=y
> 
> I wonder what kind of struct page memory layout is used, and also if
> deferred struct pages are enabled or not.

I uploaded configs and console logs (for the real hardware and for the 
virtual machine) here: 
http://people.redhat.com/~mpatocka/testcases/arm64-config/

The virtual machine was running the lvm2 testsuite while the crash 
happened.

> Have you tried bisecting the problem?

I may try some old kernel in the virtual machine to test if the bug 
happens on it.

> Thank you,
> Pavel

Mikulas
