Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C53286B004D
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 15:23:57 -0500 (EST)
Date: Wed, 27 Jan 2010 22:20:19 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 00 of 31] Transparent Hugepage support #7
Message-ID: <20100127202019.GA2294@redhat.com>
References: <patchbomb.1264513915@v2.random> <20100126175532.GA3359@redhat.com> <20100127000029.GC30452@random.random> <20100127003202.GF30452@random.random> <20100127004718.GG30452@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100127004718.GG30452@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 27, 2010 at 01:47:18AM +0100, Andrea Arcangeli wrote:
> and this incremental one too or address won't be just right...

Hi Andrea, after applying these two patches, my laptop
boots fine now, and I have not seen any more issues.

Thanks!

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
