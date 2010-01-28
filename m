Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 669926001DA
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 10:34:58 -0500 (EST)
Date: Thu, 28 Jan 2010 15:34:42 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 12 of 31] config_transparent_hugepage
Message-ID: <20100128153441.GD7139@csn.ul.ie>
References: <patchbomb.1264513915@v2.random> <e3f4fc366daf5ba210ab.1264513927@v2.random> <20100126193415.GQ16468@csn.ul.ie> <20100127195439.GB13766@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100127195439.GB13766@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 27, 2010 at 08:54:39PM +0100, Andrea Arcangeli wrote:
> On Tue, Jan 26, 2010 at 07:34:15PM +0000, Mel Gorman wrote:
> > Are there embedded x86-64 boxen? I'm surprised it's not a normal option
> 
> atom 200 4w TDP 64bit, atom 300 8 W 64bit. For some apps atom might be
> enough (not for my embedded usages though, my carpc is core 2 duo).
> 
> > and is selected by default but don't have a problem with it as such.
> 
> It's possible to disable on embedded to save a few kbytes of .text if
> they're not using the feature.
> 

Ok, seems sensible. Atom should have sprung to mind but it didn't.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
