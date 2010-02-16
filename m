Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5273E6B007B
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 02:23:55 -0500 (EST)
Date: Tue, 16 Feb 2010 18:23:49 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: add comment about deprecation of __GFP_NOFAIL
Message-ID: <20100216072349.GI5723@laptop>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1002151419260.26927@chino.kir.corp.google.com>
 <20100216085706.c7af93e1.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1002151606320.14484@chino.kir.corp.google.com>
 <20100216092147.85ef7619.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1002151712290.23480@chino.kir.corp.google.com>
 <20100216102626.5f6f0e11.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1002152300580.2745@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1002152300580.2745@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 15, 2010 at 11:03:50PM -0800, David Rientjes wrote:
> On Tue, 16 Feb 2010, KAMEZAWA Hiroyuki wrote:
> 
> > I hope no 3rd vendor (proprietary) driver uses __GFP_NOFAIL, they tend to
> > believe API is trustable and unchanged.
> > 
> 
> I hope they don't use it with GFP_ATOMIC, either, because it's never been 
> respected in that context.  We can easily audit the handful of cases in 
> the kernel that use __GFP_NOFAIL (it takes five minutes at the max) and 
> prove that none use it with GFP_ATOMIC or GFP_NOFS.  We don't need to add 
> multitudes of warnings about using a deprecated flag with ludicrous 
> combinations (does anyone really expect GFP_ATOMIC | __GFP_NOFAIL to work 
> gracefully)?

You don't need to add warnings, just don't break existing working
combinations and nobody has anything to complain about.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
