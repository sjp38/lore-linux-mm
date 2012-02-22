Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 43B5A6B00E7
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 11:29:44 -0500 (EST)
Date: Wed, 22 Feb 2012 10:29:40 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] oom: add sysctl to enable slab memory dump
In-Reply-To: <20120222161440.GB1986@x61.redhat.com>
Message-ID: <alpine.DEB.2.00.1202221028340.10258@router.home>
References: <20120222115320.GA3107@x61.redhat.com> <alpine.DEB.2.00.1202220754140.21637@router.home> <20120222161440.GB1986@x61.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, Randy Dunlap <rdunlap@xenotime.net>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Josef Bacik <josef@redhat.com>, linux-kernel@vger.kernel.org

On Wed, 22 Feb 2012, Rafael Aquini wrote:

> On Wed, Feb 22, 2012 at 07:55:16AM -0600, Christoph Lameter wrote:
> >
> > Please use node_nr_objects() instead of directly accessing total_objects.
> > total_objects are only available if debugging support was compiled in.
> >
> Shame on me! I've wrongly assumed that it would be safe accessing
> the element because SLUB_DEBUG is turned on by default when slub is chosen.
>
> Considering your note on my previous mistake, shall I assume now that it
> would be better having this whole dump feature dependable on CONFIG_SLUB_DEBUG,
> instead of just CONFIG_SLUB ?

That is certainly one solution. If CONFIG_SLUB_DEBUG is not set then
support for maintaining a total count is not compiled in. You can of
course still approximate that from the total number of slabs allocated and
multiply that number by the # of objs per slab page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
