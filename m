Date: Fri, 21 Jan 2000 13:54:26 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] 2.2.1{3,4,5} VM fix
In-Reply-To: <Pine.LNX.4.10.10001210337350.27593-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.4.21.0001211353200.486-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Jan 2000, Rik van Riel wrote:

>Below .min only GFP_ATOMIC and PF_MEMALLOC allocations
>should be allowed.
>
>This is how the priorities have been intended
>from the start on (except that we didn't have the

Very wrong. Since 2.1.x all GFP_KERNEL allocations (not atomic) succeed
too.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
