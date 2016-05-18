Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id EBC806B0260
	for <linux-mm@kvack.org>; Tue, 17 May 2016 21:42:25 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id d62so75720082iof.1
        for <linux-mm@kvack.org>; Tue, 17 May 2016 18:42:25 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id a134si17597145itc.56.2016.05.17.18.42.24
        for <linux-mm@kvack.org>;
        Tue, 17 May 2016 18:42:25 -0700 (PDT)
Date: Wed, 18 May 2016 10:42:29 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] mm: disable fault around on emulated access bit architecture
Message-ID: <20160518014229.GB21538@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.j.williams@intel.com, mgorman@suse.de, vbabka@suse.cz, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, hughd@google.com, linux-arch@vger.kernel.org

On Tue, May 17, 2016 at 03:34:23PM +0300, Kirill A. Shutemov wrote:
> On Mon, May 16, 2016 at 11:56:32PM +0900, Minchan Kim wrote:
> > On Mon, May 16, 2016 at 05:29:00PM +0300, Kirill A. Shutemov wrote:
> > > > Kirill,
> > > > You wanted to test non-HW access bit system and I did.
> > > > What's your opinion?
> > > 
> > > Sorry, for late response.
> > > 
> > > My patch is incomlete: we need to find a way to not mark pte as old if we
> > > handle page fault for the address the pte represents.
> > 
> > I'm sure you can handle it but my point is there wouldn't be a big gain
> > although you can handle it in non-HW access bit system. Okay, let's be
> > more clear because I don't have every non-HW access bit architecture.
> > At least, current mobile workload in ARM which I have wouldn't be huge
> > benefit.
> > I will say one more.
> > I tested the workload on quad-core system and core speed is not so slow
> > compared to recent other mobile phone SoC. Even when I tested the benchmark
> > without pte_mkold, the benefit is within noise because storage is really
> > slow so major fault is dominant factor. So, I decide test storage from eMMC
> > to eSATA. And then finally, I manage to see the a little beneift with
> > fault_around without pte_mkold.
> > 
> > However, let's consider side-effect aspect from fault_around.
> > 
> > 1. Increase slab shrinking compard to old
> > 2. high level vmpressure compared to old
> > 
> > With considering that regressions on my system, it's really not worth to
> > try at the moment.
> > That's why I wanted to disable fault_around as default in non-HW access
> > bit system.
> 
> Feel free to post such patch. I guess it's reasonable.
