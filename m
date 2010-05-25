Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C2DE46B01B0
	for <linux-mm@kvack.org>; Tue, 25 May 2010 13:35:08 -0400 (EDT)
Received: by fg-out-1718.google.com with SMTP id 16so303330fgg.8
        for <linux-mm@kvack.org>; Tue, 25 May 2010 10:35:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100525171959.GH20853@laptop>
References: <AANLkTimhTfz_mMWNh_r18yapNxSDjA7wRDnFM6L5aIdE@mail.gmail.com>
	<20100525081634.GE5087@laptop>
	<AANLkTilJBY0sinB365lIZFUaMgMCZ1xyhMdXRTJTVDSV@mail.gmail.com>
	<20100525093410.GH5087@laptop>
	<AANLkTikXp5LlKLK1deKOQpciUFNugjlQah5QpNcImf39@mail.gmail.com>
	<20100525101924.GJ5087@laptop>
	<AANLkTimazVL8G-XQURiQ1s0M3NKa2ndXNceSaw9sADRQ@mail.gmail.com>
	<alpine.LFD.2.00.1005250812100.3689@i5.linux-foundation.org>
	<20100525154352.GB20853@laptop>
	<AANLkTilEIwPSN-stGGuu5wV4Q6Ty0GytNMpfq-vRpK_k@mail.gmail.com>
	<20100525171959.GH20853@laptop>
Date: Tue, 25 May 2010 20:35:05 +0300
Message-ID: <AANLkTinqDzRcWd9RzS_o8BUy7uWCls_4jIhWtdYcF5Uo@mail.gmail.com>
Subject: Re: [RFC V2 SLEB 00/14] The Enhanced(hopefully) Slab Allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, May 25, 2010 at 8:19 PM, Nick Piggin <npiggin@suse.de> wrote:
>> I'm not totally convinced but I guess we're about to find that out.
>> How do you propose we benchmark SLAB while we clean it up
>
> Well the first pass will be code cleanups, bootstrap simplifications.
> Then looking at what debugging features were implemented in SLUB but not
> SLAB and what will be useful to bring over from there.

Bootstrap might be easy to clean up but the biggest source of cruft
comes from the deeply inlined, complex allocation paths. Cleaning
those up is bound to cause performance regressions if you're not
careful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
