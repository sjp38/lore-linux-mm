Date: Tue, 8 Jan 2008 14:10:20 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 02/19] free swap space on swap-in/activation
In-Reply-To: <20080108205958.947621624@redhat.com>
Message-ID: <Pine.LNX.4.64.0801081408280.4281@schroedinger.engr.sgi.com>
References: <20080108205939.323955454@redhat.com> <20080108205958.947621624@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jan 2008, Rik van Riel wrote:

> Free swap cache entries when swapping in pages if vm_swap_full()
> [swap space > 1/2 used?].  Uses new pagevec to reduce pressure
> on locks.

The pagevec function would be faster if the swap removal could be batched 
inside of the locks taken in remove_exclusive_swap_page.

Reviewed-by: Christoph Lameter <clameter@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
