Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: [RFC] Page table sharing
Date: Tue, 19 Feb 2002 12:39:15 +0100
References: <Pine.LNX.4.33.0202181908210.24803-100000@home.transmeta.com>
In-Reply-To: <Pine.LNX.4.33.0202181908210.24803-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E16d8c8-0001Ea-00@starship.berlin>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Hugh Dickins <hugh@veritas.com>, dmccr@us.ibm.com, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Robert Love <rml@tech9.net>, mingo@redhat.co, Andrew Morton <akpm@zip.com.au>, manfred@colorfullife.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On February 19, 2002 04:22 am, Linus Torvalds wrote:
> That still leaves the TLB invalidation issue, but we could handle that
> with an alternate approach: use the same "free_pte_ctx" kind of gathering
> that the zap_page_range() code uses for similar reasons (ie gather up the
> pte entries that you're going to free first, and then do a global
> invalidate later).

I think I'll fall back to unsharing the page table on swapout as Hugh 
suggested, until we sort this out.

It's not that bad.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
