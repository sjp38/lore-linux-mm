Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C0C7E6B0071
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 10:08:10 -0500 (EST)
Date: Thu, 11 Feb 2010 10:07:12 -0500
From: Nick Bowler <nbowler@elliptictech.com>
Subject: Re: [patch 4/7 -mm] oom: badness heuristic rewrite
Message-ID: <20100211150712.GA13140@emergent.ellipticsemi.com>
References: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1002100228540.8001@chino.kir.corp.google.com>
 <4B73833D.5070008@redhat.com>
 <alpine.DEB.2.00.1002102332200.22152@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1002102332200.22152@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 01:14 Thu 11 Feb     , David Rientjes wrote:
> On Wed, 10 Feb 2010, Rik van Riel wrote:
> 
> > > OOM_ADJUST_MIN and OOM_ADJUST_MAX have been exported to userspace since
> > > 2006 via include/linux/oom.h.  This alters their values from -16 to -1000
> > > and from +15 to +1000, respectively.

<snip>

> As mentioned in the changelog, we've exported these minimum and maximum 
> values via a kernel header file since at least 2006.  At what point do we 
> assume they are going to be used and not hardcoded into applications?  
> That was certainly the intention when making them user visible.

The thing is, even when the macros are used, their values are hardcoded
into programs once the code is run through a compiler.  That's why it's
called an ABI.

-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
