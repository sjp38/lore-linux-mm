Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C09896B0047
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 14:55:32 -0500 (EST)
Date: Wed, 27 Jan 2010 20:54:39 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 12 of 31] config_transparent_hugepage
Message-ID: <20100127195439.GB13766@random.random>
References: <patchbomb.1264513915@v2.random>
 <e3f4fc366daf5ba210ab.1264513927@v2.random>
 <20100126193415.GQ16468@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100126193415.GQ16468@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 26, 2010 at 07:34:15PM +0000, Mel Gorman wrote:
> Are there embedded x86-64 boxen? I'm surprised it's not a normal option

atom 200 4w TDP 64bit, atom 300 8 W 64bit. For some apps atom might be
enough (not for my embedded usages though, my carpc is core 2 duo).

> and is selected by default but don't have a problem with it as such.

It's possible to disable on embedded to save a few kbytes of .text if
they're not using the feature.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
