Date: Wed, 16 Apr 2008 12:22:58 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/2] MM: Make page tables relocatable -- conditional
 flush (rc9)
In-Reply-To: <20080414155702.ca7eb622.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0804161221060.14718@schroedinger.engr.sgi.com>
References: <20080414163933.A9628DCA48@localhost>
 <20080414155702.ca7eb622.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Biro <rossb@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mel@skynet.ie, apm@shadoween.org
List-ID: <linux-mm.kvack.org>

On Mon, 14 Apr 2008, Andrew Morton wrote:

> This is a large patch which is quite intrusive on the core memory
> management code.  It appears that there has been close to zero interest
> from any MM developers apart from a bit of to-and-fro back in October. 
> Probably because nobody can see why the chnges are valuable to them, and
> that's probably because you're not telling them!

The patch is interesting because it would allow the moving of page table 
pages into MOVABLE sections and reduce the size of the UNMOVABLE 
allocations signficantly (Ross: We need some numbers here). This in turn 
improves the success of the antifrag methods. May also improve lumpy 
reclaim if it can be adapted to move page table pages out of the way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
