From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: mm-more-likely-reclaim-madv_sequential-mappings.patch
Date: Sun, 19 Oct 2008 13:58:22 +1100
References: <20081015162232.f673fa59.akpm@linux-foundation.org> <200810191321.25490.nickpiggin@yahoo.com.au> <48FA9EDA.4030802@redhat.com>
In-Reply-To: <48FA9EDA.4030802@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200810191358.22874.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@saeurebad.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sunday 19 October 2008 13:43, Rik van Riel wrote:
> Nick Piggin wrote:
> > That's just handwaving. The patch still clears PG_referenced, which
> > is a shared resource, and it is wrong, conceptually. You can't argue
> > with that.
>
> I don't see an easy way around that.  If the PG_referenced bit is
> set and the page is mapped, the code in vmscan.c will move the
> page to the active list.
>
> Even if the one pte mapping the page is in an MADV_SEQUENTIAL
> VMA, in which case we definately do not want to activate the page.
>
> Of course, if the PG_referenced came from a different access, things
> would be a different matter.
>
> Fixing the page fault code so that it does not set the PG_referenced bit
> would take care of that.

Yes, I skeched my plan to fix this in a previous mail.

Take the mark_page_accessed out of the page fault handler; put it into
the unmap path in replacement of the SetPageReferenced; then modify
this patch so it doesn't fiddle with references that aren't hinted.

I'm just going to wait for Andrew to do his merges before sending
patches. There is no pressing need to merge this madv patch *right now*,
so it can wait I think.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
