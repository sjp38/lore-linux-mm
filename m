Date: Mon, 20 Aug 2007 12:00:49 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 2/9] Use NOMEMALLOC reclaim to allow reclaim if PF_MEMALLOC
 is set
In-Reply-To: <20070818071035.GA4667@ucw.cz>
Message-ID: <Pine.LNX.4.64.0708201158270.28863@schroedinger.engr.sgi.com>
References: <20070814153021.446917377@sgi.com> <20070814153501.305923060@sgi.com>
 <20070818071035.GA4667@ucw.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Sat, 18 Aug 2007, Pavel Machek wrote:

> > The reclaim is of particular important to stacked filesystems that may
> > do a lot of allocations in the write path. Reclaim will be working
> > as long as there are clean file backed pages to reclaim.
> 
> I don't get it. Lets say that we have stacked filesystem that needs
> it. That filesystem is broken today.
> 
> Now you give it second chance by reclaiming clean pages, but there are
> no guarantees that we have any.... so that filesystem is still broken
> with your patch...?

There is a guarantee that we have some because the user space program is 
executing. Meaning the executable pages can be retrieved. The amount 
dirty memory in the system is limited by the dirty_ratio. So the VM can 
only get into trouble if there is a sufficient amount of anonymous pages 
and all executables have been reclaimed. That is pretty rare.

Plus the same issue can happen today. Writes are usually not completed 
during reclaim. If the writes are sufficiently deferred then you have the 
same issue now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
