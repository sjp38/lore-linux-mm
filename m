Date: Sun, 23 Nov 2003 14:36:27 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] Make balance_dirty_pages zone aware (1/2)
Message-Id: <20031123143627.1754a3f0.akpm@osdl.org>
In-Reply-To: <3FBEB27D.5010007@us.ibm.com>
References: <3FBEB27D.5010007@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: colpatch@us.ibm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@aracnet.com, akpm@digeo.com
List-ID: <linux-mm.kvack.org>

Matthew Dobson <colpatch@us.ibm.com> wrote:
>
> Currently the VM decides to start doing background writeback of pages if 
>  10% of the systems pages are dirty, and starts doing synchronous 
>  writeback of pages if 40% are dirty.  This is great for smaller memory 
>  systems, but in larger memory systems (>2GB or so), a process can dirty 
>  ALL of lowmem (ZONE_NORMAL, 896MB) without hitting the 40% dirty page 
>  ratio needed to force the process to do writeback. 

Yes, it has been that way for a year or so.  I was wondering if anyone
would hit any problems in practice.  Have you hit any problem in practice?

I agree that the per-zonification of this part of the VM/VFS makes some
sense, although not _complete_ sense, because as you've seen, we need to
perform writeout against all zones' pages if _any_ zone exceeds dirty
limits.  This could do nasty things on a 1G highmem machine, due to the
tiny highmem zone.  So maybe that zone should not trigger writeback.

However the simplest fix is of course to decrease the default value of the
dirty thresholds - put them back to the 2.4 levels.  It all depends upon
the nature of the problems which you have been observing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
