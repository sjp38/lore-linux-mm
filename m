Date: Fri, 29 Apr 2005 17:51:08 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] Remove struct reclaim_state
Message-Id: <20050429175108.242c410e.akpm@osdl.org>
In-Reply-To: <42718AA1.5010805@us.ibm.com>
References: <42718AA1.5010805@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@aracnet.com
List-ID: <linux-mm.kvack.org>

Matthew Dobson <colpatch@us.ibm.com> wrote:
>
> Since shrink_slab() currently returns 0 no matter what happens,
>  I changed it to return the number of slab pages freed.

A sane cleanup, but it conflicts with vmscan-notice-slab-shrinking.patch,
which returns a different thing from shrink_slab() in order to account for
slab reclaim only causing internal fragmentation and not actually freeing
pages yet.

vmscan-notice-slab-shrinking.patch isn't quite complete yet, but we do need
to do something along these lines.  I need to get back onto it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
