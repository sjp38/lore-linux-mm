Date: Tue, 8 Apr 2008 14:22:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 18/18] dentries: dentry defragmentation
Message-Id: <20080408142232.8ac243bc.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0804081409270.31230@schroedinger.engr.sgi.com>
References: <20080404230158.365359425@sgi.com>
	<20080404230229.922470579@sgi.com>
	<20080407231434.88352977.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0804081409270.31230@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Apr 2008 14:14:33 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> > More importantly - what is the worst success rate, and under which
> > circumstances will it occur, and what are the consequences?
> 
> If just dentries remain that are pinned then the function 
> will not succeed and the slab page will be marked unkickable and no longer 
> scanned.

That doesn't address my overall concern here.

We know from hard experience that scanning code tends to have failure
scenarios where it expends large amounts of CPU time not achieving much.

What workloads are most likely to trigger that sort of behaviour with these
changes?  How do we establish such failure scenarios and test them?

It could be that the non-kickable flag saves us from all such cases, dunno.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
