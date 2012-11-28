Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 479016B0044
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 20:30:48 -0500 (EST)
Date: Tue, 27 Nov 2012 23:30:31 -0200
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH] mm: fix balloon_page_movable() page->flags check
Message-ID: <20121128013031.GA2071@x61.redhat.com>
References: <20121127145708.c7173d0d.akpm@linux-foundation.org>
 <1ccb1c95a52185bcc6009761cb2829197e2737ea.1354058194.git.aquini@redhat.com>
 <20121127155201.ddfea7e1.akpm@linux-foundation.org>
 <20121128003409.GB7401@t510.redhat.com>
 <20121127171544.8bbb702a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121127171544.8bbb702a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>

On Tue, Nov 27, 2012 at 05:15:44PM -0800, Andrew Morton wrote:
> On Tue, 27 Nov 2012 22:34:10 -0200 Rafael Aquini <aquini@redhat.com> wrote:
> 
> > Do you want me to resubmit this patch with the changes you suggested?
> 
> oh, I think I can reach that far.  How's this look?
>

It looks great to me.

Just a small nitpick, 
here __balloon_page_flags should be changed to page_flags_cleared too:
> @@ -109,18 +110,16 @@ static inline void balloon_mapping_free(
>  /*
>   * __balloon_page_flags - helper to perform balloon @page ->flags tests.
>   *

Thanks!
--Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
