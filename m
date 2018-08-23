Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0C4D16B29BD
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 07:10:27 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id w44-v6so2149950edb.16
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 04:10:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i59-v6si1675914edc.458.2018.08.23.04.10.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 04:10:25 -0700 (PDT)
Date: Thu, 23 Aug 2018 13:10:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: A crash on ARM64 in move_freepages_block due to uninitialized
 pages in reserved memory
Message-ID: <20180823111024.GC29735@dhcp22.suse.cz>
References: <alpine.LRH.2.02.1808171527220.2385@file01.intranet.prod.int.rdu2.redhat.com>
 <20180821104418.GA16611@dhcp22.suse.cz>
 <e35b7c14-c7ea-412d-2763-c961b74576f3@arm.com>
 <alpine.LRH.2.02.1808220808050.17906@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1808220808050.17906@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: James Morse <james.morse@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Pavel Tatashin <Pavel.Tatashin@microsoft.com>

On Thu 23-08-18 07:02:37, Mikulas Patocka wrote:
[...]
> This crash is not from -ENOENT. It crashes because page->compound_head is 
> 0xffffffffffffffff (see below).
> 
> If I enable CONFIG_DEBUG_VM, I also get VM_BUG.

This smells like the struct page is not initialized properly. How is
this memory range added? I mean is it brought up by the memory hotplug
or during the boot?
-- 
Michal Hocko
SUSE Labs
