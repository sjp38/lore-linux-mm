Date: Tue, 8 Jan 2008 14:42:03 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 05/19] split LRU lists into anon & file sets
In-Reply-To: <20080108173634.5ed3b0d4@bree.surriel.com>
Message-ID: <Pine.LNX.4.64.0801081441090.4678@schroedinger.engr.sgi.com>
References: <20080108205939.323955454@redhat.com> <20080108210002.638347207@redhat.com>
 <Pine.LNX.4.64.0801081421530.4281@schroedinger.engr.sgi.com>
 <20080108173634.5ed3b0d4@bree.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jan 2008, Rik van Riel wrote:

> > Also would it be possible to create generic functions that can move pages 
> > in pagevecs to an arbitrary lru list?
> 
> What would you use those functions for?

We keep on duplicating the pagevec lru operation functions in mm/swap.c. 
Some generic stuff would reduce the code size.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
