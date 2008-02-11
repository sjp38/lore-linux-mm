Date: Mon, 11 Feb 2008 11:14:21 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB tbench regression due to page allocator deficiency
In-Reply-To: <20080210232401.GA5621@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0802111113410.24379@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0802091332450.12965@schroedinger.engr.sgi.com>
 <20080209143518.ced71a48.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0802091549120.13328@schroedinger.engr.sgi.com>
 <20080210024517.GA32721@wotan.suse.de> <Pine.LNX.4.64.0802091938160.14089@schroedinger.engr.sgi.com>
 <20080210232401.GA5621@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Pekka J Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Mon, 11 Feb 2008, Nick Piggin wrote:

> OK, that's easy... You did it with an SMP kernel, right? (I only have a
> 8p NUMA, but I should be able to turn on cacheline interleaving and
> run an SMP kernel on it).

Correct.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
