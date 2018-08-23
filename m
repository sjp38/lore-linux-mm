Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1C9AC6B29C7
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 07:16:36 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id y46-v6so4364943qth.9
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 04:16:36 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id k16-v6si955176qvc.79.2018.08.23.04.16.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 04:16:35 -0700 (PDT)
Date: Thu, 23 Aug 2018 07:16:34 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: A crash on ARM64 in move_freepages_block due to uninitialized
 pages in reserved memory
In-Reply-To: <20180823111024.GC29735@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1808230715050.30076@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1808171527220.2385@file01.intranet.prod.int.rdu2.redhat.com> <20180821104418.GA16611@dhcp22.suse.cz> <e35b7c14-c7ea-412d-2763-c961b74576f3@arm.com> <alpine.LRH.2.02.1808220808050.17906@file01.intranet.prod.int.rdu2.redhat.com>
 <20180823111024.GC29735@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: James Morse <james.morse@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Pavel Tatashin <Pavel.Tatashin@microsoft.com>



On Thu, 23 Aug 2018, Michal Hocko wrote:

> On Thu 23-08-18 07:02:37, Mikulas Patocka wrote:
> [...]
> > This crash is not from -ENOENT. It crashes because page->compound_head is 
> > 0xffffffffffffffff (see below).
> > 
> > If I enable CONFIG_DEBUG_VM, I also get VM_BUG.
> 
> This smells like the struct page is not initialized properly. How is
> this memory range added? I mean is it brought up by the memory hotplug
> or during the boot?
> -- 
> Michal Hocko
> SUSE Labs

During the boot. There's not hotplug.

Mikulas
