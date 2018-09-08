Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 40AE28E0001
	for <linux-mm@kvack.org>; Sat,  8 Sep 2018 06:24:16 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f10-v6so11161004wmb.9
        for <linux-mm@kvack.org>; Sat, 08 Sep 2018 03:24:16 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id g205-v6si8885683wma.135.2018.09.08.03.24.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sat, 08 Sep 2018 03:24:14 -0700 (PDT)
Date: Sat, 8 Sep 2018 12:24:10 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: 32-bit PTI with THP = userspace corruption
In-Reply-To: <20180831070722.wnulbbmillxkw7ke@suse.de>
Message-ID: <alpine.DEB.2.21.1809081223450.1402@nanos.tec.linutronix.de>
References: <alpine.LRH.2.21.1808301639570.15669@math.ut.ee> <20180830205527.dmemjwxfbwvkdzk2@suse.de> <alpine.LRH.2.21.1808310711380.17865@math.ut.ee> <20180831070722.wnulbbmillxkw7ke@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <jroedel@suse.de>
Cc: Meelis Roos <mroos@linux.ee>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org


On Fri, 31 Aug 2018, Joerg Roedel wrote:

> On Fri, Aug 31, 2018 at 07:12:44AM +0300, Meelis Roos wrote:
> > > Thanks for the report! I'll try to reproduce the problem tomorrow and
> > > investigate it. Can you please check if any of the kernel configurations
> > > that show the bug has CONFIG_X86_PAE set? If not, can you please test
> > > if enabling this option still triggers the problem?
> > 
> > Will check, but out of my memery there were 2 G3 HP Proliants that did 
> > not fit into the pattern (problem did not appear). I have more than 4G 
> > RAM in those and HIGHMEM_4G there, maybe that's it?
> 
> Yeah, I thought a bit about it, and for legacy paging the PMD paging
> level is the root-level where we do the mirroring between kernel and
> user page-table for PTI. This means we also need to collect A/D bits
> from both entries, which we don't do yet.
> 
> But that all means it shouldn't happen with CONFIG_X86_PAE=y.
> 
> I'll try to reproduce and work on a fix.

Any progress on this?

Thanks,

	tglx
