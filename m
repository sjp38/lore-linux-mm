Date: Thu, 18 Aug 2005 20:17:19 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] use mm_counter macros for nr_pte since its also under
 ptl
Message-Id: <20050818201719.25443ae1.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.62.0508181818100.2740@schroedinger.engr.sgi.com>
References: <20050817151723.48c948c7.akpm@osdl.org>
	<20050817174359.0efc7a6a.akpm@osdl.org>
	<Pine.LNX.4.61.0508182116110.11409@goblin.wat.veritas.com>
	<Pine.LNX.4.62.0508181818100.2740@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: hugh@veritas.com, torvalds@osdl.org, piggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@engr.sgi.com> wrote:
>
> Actually this is a bug already present in Linus' tree (but still my 
>  fault). nr_pte's needs to be managed through the mm counter macros like
>  other counters protected by the page table fault. 

Does that mean that Linus's tree can presently go BUG?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
