Date: Tue, 12 Feb 2008 12:12:14 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 0/3] Hotcold removal completion
In-Reply-To: <20080211235714.1484b0c7.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0802121210400.2204@schroedinger.engr.sgi.com>
References: <20080212003643.536643832@sgi.com> <200802121732.29593.nickpiggin@yahoo.com.au>
 <20080211235714.1484b0c7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Mon, 11 Feb 2008, Andrew Morton wrote:

> I think I'd prefer that we convince ourselves that we didn't just merge a
> regression rather than merging more stuff on top of it.  Because right now,
> page-allocator-get-rid-of-the-list-of-cold-pages.patch reverts cleanly.

Well Mel and I discussed this extensively and I have tried to get these 
patches merged before (early Jan) because I saw the danger of the half 
assed stuff getting merged. Either we should backout the half baked stuff 
upstream now or go the full way and remove the hot/cold distinction.
\

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
