Date: Wed, 6 Aug 2003 16:49:18 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Free list initialization
Message-ID: <20030806234918.GN8121@holomorphy.com>
References: <2110.128.2.222.155.1060209130.squirrel@webmail.andrew.cmu.edu> <739780000.1060211566@flay>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <739780000.1060211566@flay>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Anand Eswaran <aeswaran@andrew.cmu.edu>, Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 06, 2003 at 04:12:46PM -0700, Martin J. Bligh wrote:
> Suggest you start at free_all_bootmem. IIRC, basically we just call a 
> free on every page we have, and the normal buddy free routines populate
> the lists. Not very efficient, but who cares? ... it's boottime! ;-)

If it ever turns out that someone does care, I've gone through and done
useful things like freeing higher-order pages at a time for both
bootmem.c and highmem (as isolated patches) I could resurrect if the
issue ever arises in the field.

The whole affair is still asymptotically O(pages) since the coremap
initialization still touches every struct page, so there aren't large
amounts of improvement that can be made without dynamically allocating
coremap elements (which raises more issues than it resolves, though
there are valid reasons to want to do it beyond this).


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
