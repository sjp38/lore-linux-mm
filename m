Date: Mon, 18 Oct 1999 13:02:12 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] kanoj-mm17-2.3.21 kswapd vma scanning protection
In-Reply-To: <199910181945.MAA81369@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.9910181301470.1835-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 18 Oct 1999, Kanoj Sarcar wrote:
> 
> Here is the reworked vma scanning protection patch against 2.3.22.
> This patch has to get one less lock in the page stealing path 
> compared to the previous patch that I posted. Let me know if this 
> looks okay now, and I will send you an incremental swapout() interface 
> cleanup patch that we have discussed.

Looks ok to me now. Thanks,

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
