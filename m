Date: Mon, 5 Mar 2007 18:46:31 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc][patch 2/2] mm: mlocked pages off LRU
In-Reply-To: <20070306021307.GE23845@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0703051845050.17203@schroedinger.engr.sgi.com>
References: <20070305161746.GD8128@wotan.suse.de>
 <Pine.LNX.4.64.0703050948040.6620@schroedinger.engr.sgi.com>
 <20070306010529.GB23845@wotan.suse.de> <Pine.LNX.4.64.0703051723240.16842@schroedinger.engr.sgi.com>
 <20070306014403.GD23845@wotan.suse.de> <Pine.LNX.4.64.0703051753070.16964@schroedinger.engr.sgi.com>
 <20070306021307.GE23845@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

On Tue, 6 Mar 2007, Nick Piggin wrote:

> > The above is a bit contradictory. Assuming they are taken off the LRU:
> > How will they be returned to the LRU?
> 
> In what way is it contradictory? If they are mlocked, we put them on the
> LRU when they get munlocked. If they are off the LRU due to a !swap condition,
> then we put them back on the LRU by whatever mechanism that uses (eg. a
> 3rd LRU list that we go through much more slowly...).

Ok how are we going to implement the 3rd LRU for non mlocked anonymous 
pages if you use the lru for the refcounter field? Another page flags bit? 
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
