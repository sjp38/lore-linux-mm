Date: Sun, 2 Dec 2007 03:58:57 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] mm: fix confusing __GFP_REPEAT related comments
Message-ID: <20071202115857.GB31637@holomorphy.com>
References: <20071129214828.GD20882@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071129214828.GD20882@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: haveblue@us.ibm.com, akpm@linux-foundation.org, mel@skynet.ie, apw@shadowen.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 29, 2007 at 01:48:28PM -0800, Nishanth Aravamudan wrote:
> The definition and use of __GFP_REPEAT, __GFP_NOFAIL and __GFP_NORETRY
> in the core VM have somewhat differing comments as to their actual
> semantics. Annoyingly, the flags definition has inline and header
> comments, which might be interpreted as not being equivalent. Just add
> references to the header comments in the inline ones so they don't go
> out of sync in the future. In their use in __alloc_pages() clarify that
> the current implementation treats low-order allocations and __GFP_REPEAT
> allocations as distinct cases, albeit currently with the same result.

This is a bit beyond the scope of the patch, but doesn't the obvious
livelock behavior here disturb anyone else?


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
