Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id AB8416B004D
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 12:30:01 -0500 (EST)
Date: Wed, 27 Jan 2010 17:29:41 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 01 of 31] define MADV_HUGEPAGE
In-Reply-To: <20100127171316.GC12736@random.random>
Message-ID: <alpine.LSU.2.00.1001271726410.30975@sister.anvils>
References: <patchbomb.1264513915@v2.random> <da09747e3b1d0368a0a6.1264513916@v2.random> <alpine.LSU.2.00.1001271600450.25739@sister.anvils> <20100127171316.GC12736@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Wed, 27 Jan 2010, Andrea Arcangeli wrote:
> 
> I've no problem to do the not-lazy way of madv-common.h, and yes I
> think it's less confusing to have one number for all archs...
> 
> Let's say, to me the important thing is we agree on one number,

It is important to stabilize on a number, instead of having it shift
from one version of the patchset to another; but I don't think it's
important that the same number be used on every architecture.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
