Date: Fri, 19 Jan 2007 11:01:57 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RPC][PATCH 2.6.20-rc5] limit total vfs page cache
In-Reply-To: <45B112B6.9060806@linux.vnet.ibm.com>
Message-ID: <Pine.LNX.4.64.0701191059020.15546@schroedinger.engr.sgi.com>
References: <6d6a94c50701171923g48c8652ayd281a10d1cb5dd95@mail.gmail.com>
 <45B0DB45.4070004@linux.vnet.ibm.com> <6d6a94c50701190805saa0c7bbgbc59d2251bed8537@mail.gmail.com>
 <45B112B6.9060806@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Cc: Aubrey Li <aubreylee@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, "linux-os (Dick Johnson)" <linux-os@analogic.com>, Robin Getz <rgetz@blackfin.uclinux.org>
List-ID: <linux-mm.kvack.org>

On Sat, 20 Jan 2007, Vaidyanathan Srinivasan wrote:

> >> However when the zone reclaimer starts to reclaim pages, it will
> >> remove all cold pages and not specifically pagecache pages.  This
> >> may affect performance of applications.

The reclaimer is passed a control structure that can be used to disable
write to swap (if that is the concern).

> I am open to suggestions on reclaim logic.  My view is that we need
> to selectively reclaim pagecache pages and not just call the
> traditional reclaimer to freeup arbitrary type of pages.

The traditional reclaim works fine if told what to do. Introducing another 
LRU list to do reclaim is a significant change to the VM, creates lots of
overhead etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
