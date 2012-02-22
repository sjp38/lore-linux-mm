Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 862136B0083
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 11:16:16 -0500 (EST)
Date: Wed, 22 Feb 2012 14:14:41 -0200
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH] oom: add sysctl to enable slab memory dump
Message-ID: <20120222161440.GB1986@x61.redhat.com>
References: <20120222115320.GA3107@x61.redhat.com>
 <alpine.DEB.2.00.1202220754140.21637@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1202220754140.21637@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Randy Dunlap <rdunlap@xenotime.net>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Josef Bacik <josef@redhat.com>, linux-kernel@vger.kernel.org

On Wed, Feb 22, 2012 at 07:55:16AM -0600, Christoph Lameter wrote:
> 
> Please use node_nr_objects() instead of directly accessing total_objects.
> total_objects are only available if debugging support was compiled in.
> 
Shame on me! I've wrongly assumed that it would be safe accessing
the element because SLUB_DEBUG is turned on by default when slub is chosen.

Considering your note on my previous mistake, shall I assume now that it
would be better having this whole dump feature dependable on CONFIG_SLUB_DEBUG,
instead of just CONFIG_SLUB ?

Thanks for your feedback!
-- 
Rafael Aquini <aquini@redhat.com>
Software Maintenance Engineer
Red Hat, Inc.
+55 51 4063.9436 / 8426138 (ext)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
