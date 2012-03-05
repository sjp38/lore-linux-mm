Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id EF5B26B002C
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 09:48:37 -0500 (EST)
Date: Mon, 5 Mar 2012 08:48:33 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -next] slub: set PG_slab on all of slab pages
In-Reply-To: <20120304103446.GA9267@barrios>
Message-ID: <alpine.DEB.2.00.1203050845380.11722@router.home>
References: <1330505674-31610-1-git-send-email-namhyung.kim@lge.com> <20120304103446.GA9267@barrios>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Namhyung Kim <namhyung.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Namhyung Kim <namhyung@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 4 Mar 2012, Minchan Kim wrote:

> I read this thread and I feel the we don't reach right point.
> I think it's not a compound page problem.
> We can face above problem where we allocates big order page without __GFP_COMP
> and free middle page of it.

Yes we can do that and doing such a thing seems to be more legitimate
since one could argue that the user did not request an atomic allocation
unit from the page allocator and therefore the freeing of individual
pages in that group is permissible. If memory serves me right we do that
sometimes.

However if compound pages are requested then such an atomic allocation
unit *was* requested and the page allocator should not allow to free
individual pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
