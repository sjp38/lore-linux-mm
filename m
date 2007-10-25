Date: Wed, 24 Oct 2007 19:25:24 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 14/14] bufferhead: Revert constructor removal
In-Reply-To: <20071022143147.03de69ca.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0710241924060.29434@schroedinger.engr.sgi.com>
References: <20070925232543.036615409@sgi.com> <20070925233008.731010041@sgi.com>
 <20071022143147.03de69ca.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 22 Oct 2007, Andrew Morton wrote:

> So I see no need for this patch?  Shouldn't it be part of a slab-defrag
> patch series?

It could be part of it. However, I think we mistakenly merged the removal 
of the constuctor into a cleanup patch. You had a test that showed that 
the removal of the constructor led to a small regression. The prior state 
makes things easier for slab defrag.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
