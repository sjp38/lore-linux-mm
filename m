Date: Sat, 12 Jun 1999 12:21:07 +0200
From: Andi Kleen <ak@muc.de>
Subject: Re: Some issues + [PATCH] kanoj-mm8-2.2.9 Show statistics on alloc/free requests for each pagefree list
Message-ID: <19990612122107.A2245@fred.muc.de>
References: <199906120102.SAA64168@google.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <199906120102.SAA64168@google.engr.sgi.com>; from Kanoj Sarcar on Sat, Jun 12, 1999 at 03:02:18AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: linux-mm@kvack.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

On Sat, Jun 12, 1999 at 03:02:18AM +0200, Kanoj Sarcar wrote:
> Anyway, this raises some interesting questions about the buddy algorithm.
> Is it really worth aggressively coalescing pages on each free? Wouldn't
> it be better to lazily coalesce pages (maybe by a kernel thread), or even
> on demand? By far, the most number of requests are coming for the 4K pages,
> followed by 8K (task/stack pair). A kernel compile is no representative
> app, but I would be surprised if there are too many apps/drivers which 
> will force bigger page requests, once kernel initialization is complete.
> Wouldn't it be better to optimize the more common case?

There is a important case ATM that needs bigger blocks allocated from 
bottom half context: NFS packet defragmenting. For a 8K wsize it needs
even 16K blocks (8K payload + the IP/UDP header forces it to the next
buddy size). I guess your statistics would look very different on a nfsroot
machine. Until lazy defragmenting is supported for UDP it is probably 
better not to change it.


-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
