Subject: Re: [RFC] Reserve huge pages for reliable MAP_PRIVATE hugetlbfs mappings
From: Andi Kleen <andi@firstfloor.org>
References: <20080421183621.GA13100@csn.ul.ie>
Date: Wed, 23 Apr 2008 15:55:10 +0200
In-Reply-To: <20080421183621.GA13100@csn.ul.ie> (Mel Gorman's message of "Mon, 21 Apr 2008 19:36:22 +0100")
Message-ID: <87hcdsznep.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: wli@holomorphy.com, agl@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Mel Gorman <mel@csn.ul.ie> writes:

> MAP_SHARED mappings on hugetlbfs reserve huge pages at mmap() time. This is
> so that all future faults will be guaranteed to succeed. Applications are not
> expected to use mlock() as this can result in poor NUMA placement.
>
> MAP_PRIVATE mappings do not reserve pages. This can result in an application
> being SIGKILLed later if a large page is not available at fault time. This
> makes huge pages usage very ill-advised in some cases as the unexpected
> application failure is intolerable. Forcing potential poor placement with
> mlock() is not a great solution either.
>
> This patch reserves huge pages at mmap() time for MAP_PRIVATE mappings similar
> to what happens for MAP_SHARED mappings. 

This will break all applications that mmap more hugetlbpages than they
actually use. How do you know these don't exist?

> Opinions?

Seems like a risky interface change to me.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
