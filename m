Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 70C176B55AA
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 03:07:25 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id x24-v6so4458787edm.13
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 00:07:25 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r9-v6si1501292edp.9.2018.08.31.00.07.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Aug 2018 00:07:23 -0700 (PDT)
Date: Fri, 31 Aug 2018 09:07:22 +0200
From: Joerg Roedel <jroedel@suse.de>
Subject: Re: 32-bit PTI with THP = userspace corruption
Message-ID: <20180831070722.wnulbbmillxkw7ke@suse.de>
References: <alpine.LRH.2.21.1808301639570.15669@math.ut.ee>
 <20180830205527.dmemjwxfbwvkdzk2@suse.de>
 <alpine.LRH.2.21.1808310711380.17865@math.ut.ee>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.21.1808310711380.17865@math.ut.ee>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Meelis Roos <mroos@linux.ee>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

On Fri, Aug 31, 2018 at 07:12:44AM +0300, Meelis Roos wrote:
> > Thanks for the report! I'll try to reproduce the problem tomorrow and
> > investigate it. Can you please check if any of the kernel configurations
> > that show the bug has CONFIG_X86_PAE set? If not, can you please test
> > if enabling this option still triggers the problem?
> 
> Will check, but out of my memery there were 2 G3 HP Proliants that did 
> not fit into the pattern (problem did not appear). I have more than 4G 
> RAM in those and HIGHMEM_4G there, maybe that's it?

Yeah, I thought a bit about it, and for legacy paging the PMD paging
level is the root-level where we do the mirroring between kernel and
user page-table for PTI. This means we also need to collect A/D bits
from both entries, which we don't do yet.

But that all means it shouldn't happen with CONFIG_X86_PAE=y.

I'll try to reproduce and work on a fix.

Thanks,

	Joerg
