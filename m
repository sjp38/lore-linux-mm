Date: Fri, 21 Feb 2003 00:43:17 -0300 (BRT)
From: Rik van Riel <riel@imladris.surriel.com>
Subject: Re: [PATCH 2.5.62] Support for remap_page_range in objrmap
In-Reply-To: <178650000.1045782627@flay>
Message-ID: <Pine.LNX.4.50L.0302210039120.2329-100000@imladris.surriel.com>
References: <121000000.1045777999@baldur.austin.ibm.com> <178650000.1045782627@flay>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Dave McCracken <dmccr@us.ibm.com>, Andrew Morton <akpm@digeo.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 20 Feb 2003, Martin J. Bligh wrote:

> > Here's the fix we discussed for remap_page_range.  It sets the anon flag
> > for pages in any vma used for nonlinear.  It also requires that
> > MAP_NONLINEAR be passed in at mmap time to flag the vma.
>
> Using the page based mechanism might also clear up some people's
> concerns about small windows onto large shared areas for Oracle,
> which will probably be using these nonlinear mappings anyway.

Good point.  Object based reverse mappings become unwieldy at about
the same point where the objects themselves get unwieldy.

A hybrid system with object based mappings in some cases and page
based mappings in other cases might work very nicely...

> Yes, I'm sure there are other corner cases that need to be addressed
> as well ;-)

There are, but at the moment I can't remember any as serious as the
"1000 tasks with 1000 small mappings of the same shared memory segment"
scenario.

This hybrid system looks like it is worth exploring.

regards,

Rik
-- 
Engineers don't grow up, they grow sideways.
http://www.surriel.com/		http://kernelnewbies.org/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
