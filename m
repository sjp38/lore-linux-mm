Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id B849C8E0005
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 08:12:25 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id a23-v6so12754035pfo.23
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 05:12:25 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y6-v6si21891721pgr.684.2018.09.11.05.12.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Sep 2018 05:12:24 -0700 (PDT)
Date: Tue, 11 Sep 2018 14:12:22 +0200
From: Joerg Roedel <jroedel@suse.de>
Subject: Re: 32-bit PTI with THP = userspace corruption
Message-ID: <20180911121128.ikwptix6e4slvpt2@suse.de>
References: <alpine.LRH.2.21.1808301639570.15669@math.ut.ee>
 <20180830205527.dmemjwxfbwvkdzk2@suse.de>
 <alpine.LRH.2.21.1808310711380.17865@math.ut.ee>
 <20180831070722.wnulbbmillxkw7ke@suse.de>
 <alpine.DEB.2.21.1809081223450.1402@nanos.tec.linutronix.de>
 <20180911114927.gikd3uf3otxn2ekq@suse.de>
 <alpine.LRH.2.21.1809111454100.29433@math.ut.ee>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.21.1809111454100.29433@math.ut.ee>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Meelis Roos <mroos@linux.ee>
Cc: Thomas Gleixner <tglx@linutronix.de>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, Sep 11, 2018 at 02:58:10PM +0300, Meelis Roos wrote:
> The machines where I have PAE off are the ones that have less memory. 
> PAE is off just for performance reasons, not lack of PAE. PAE should be 
> present on all of my affected machines anyway and current distributions 
> seem to mostly assume 686 and PAE anyway for 32-bit systems.

Right, most distributions don't even provide a non-PAE kernel for their
users anymore.

How big is the performance impact of using PAE over legacy paging? It
shouldn't be too big because the top-level of the page-table only has 4
entries and is completly cached in the CPU. This makes %cr3 switches
slower, but the page-walk itself still only needs 2 memory accesses.

The page-table entries are also 8 bytes instead of 4 bytes, so that
there is less locality in page-walks and probably a higher cache-miss
rate.

Regards,

	Joerg
