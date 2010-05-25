Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1D5F76B01B0
	for <linux-mm@kvack.org>; Tue, 25 May 2010 13:02:49 -0400 (EDT)
Received: by fxm11 with SMTP id 11so3035220fxm.14
        for <linux-mm@kvack.org>; Tue, 25 May 2010 10:02:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100525154352.GB20853@laptop>
References: <AANLkTik2O-_Fbh-dq0sSLFJyLU7PZi4DHm85lCo4sugS@mail.gmail.com>
	<20100525070734.GC5087@laptop>
	<AANLkTimhTfz_mMWNh_r18yapNxSDjA7wRDnFM6L5aIdE@mail.gmail.com>
	<20100525081634.GE5087@laptop>
	<AANLkTilJBY0sinB365lIZFUaMgMCZ1xyhMdXRTJTVDSV@mail.gmail.com>
	<20100525093410.GH5087@laptop>
	<AANLkTikXp5LlKLK1deKOQpciUFNugjlQah5QpNcImf39@mail.gmail.com>
	<20100525101924.GJ5087@laptop>
	<AANLkTimazVL8G-XQURiQ1s0M3NKa2ndXNceSaw9sADRQ@mail.gmail.com>
	<alpine.LFD.2.00.1005250812100.3689@i5.linux-foundation.org>
	<20100525154352.GB20853@laptop>
Date: Tue, 25 May 2010 20:02:32 +0300
Message-ID: <AANLkTilEIwPSN-stGGuu5wV4Q6Ty0GytNMpfq-vRpK_k@mail.gmail.com>
Subject: Re: [RFC V2 SLEB 00/14] The Enhanced(hopefully) Slab Allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Hi Nick,

On Tue, May 25, 2010 at 6:43 PM, Nick Piggin <npiggin@suse.de> wrote:
> As far as I can see, there was never a good reason to replace SLAB
> rather than clean up its code and make incremental improvements.

I'm not totally convinced but I guess we're about to find that out.
How do you propose we benchmark SLAB while we clean it up and change
things to make sure we don't make the same mistakes as we did with
SLUB (i.e. miss an important workload like TPC-C)?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
