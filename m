Message-ID: <48FA9EDA.4030802@redhat.com>
Date: Sat, 18 Oct 2008 22:43:38 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: mm-more-likely-reclaim-madv_sequential-mappings.patch
References: <20081015162232.f673fa59.akpm@linux-foundation.org> <200810181230.33688.nickpiggin@yahoo.com.au> <87fxmu41wt.fsf@saeurebad.de> <200810191321.25490.nickpiggin@yahoo.com.au>
In-Reply-To: <200810191321.25490.nickpiggin@yahoo.com.au>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Johannes Weiner <hannes@saeurebad.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
>
> That's just handwaving. The patch still clears PG_referenced, which
> is a shared resource, and it is wrong, conceptually. You can't argue
> with that.
>
>   
I don't see an easy way around that.  If the PG_referenced bit is
set and the page is mapped, the code in vmscan.c will move the
page to the active list.

Even if the one pte mapping the page is in an MADV_SEQUENTIAL
VMA, in which case we definately do not want to activate the page.

Of course, if the PG_referenced came from a different access, things
would be a different matter. 

Fixing the page fault code so that it does not set the PG_referenced bit
would take care of that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
