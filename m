MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17900.60167.418766.280544@cargo.ozlabs.ibm.com>
Date: Tue, 6 Mar 2007 15:16:07 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
In-Reply-To: <Pine.LNX.4.64.0703011939120.12485@woody.linux-foundation.org>
References: <20070301101249.GA29351@skynet.ie>
	<20070301160915.6da876c5.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0703011642190.12485@woody.linux-foundation.org>
	<45E7835A.8000908@in.ibm.com>
	<Pine.LNX.4.64.0703011939120.12485@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Balbir Singh <balbir@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@skynet.ie>, npiggin@suse.de, clameter@engr.sgi.com, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds writes:

> The point being that in the guests, hotunplug is almost useless (for 
> bigger ranges), and we're much better off just telling the virtualization 
> hosts on a per-page level whether we care about a page or not, than to 
> worry about fragmentation.

We don't have that luxury on IBM System p machines, where the
hypervisor manages memory in much larger units than a page.  Typically
the size of memory block that the hypervisor uses to manage memory is
16MB or more -- which makes sense from the point of view that if the
hypervisor had to manage individual pages, it would end up adding a
lot more overhead than it does.

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
