Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 983659000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 11:25:04 -0400 (EDT)
Date: Mon, 26 Sep 2011 10:24:59 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH 4/5] mm: Only IPI CPUs to drain local pages if they
 exist
In-Reply-To: <CAOtvUMddUAATZcU_5jLgY10ocsHNnOO2GC2c4ecYO9KGt-U7VQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1109261023400.24164@router.home>
References: <1316940890-24138-1-git-send-email-gilad@benyossef.com> <1316940890-24138-5-git-send-email-gilad@benyossef.com> <1317001924.29510.160.camel@sli10-conroe> <CAOtvUMddUAATZcU_5jLgY10ocsHNnOO2GC2c4ecYO9KGt-U7VQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: Shaohua Li <shaohua.li@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

On Mon, 26 Sep 2011, Gilad Ben-Yossef wrote:

> I do not know if these scenarios warrant the additional overhead,
> certainly not in all situations. Maybe the right thing is to make it a
> config option dependent. As I stated in the patch description, that is
> one of the thing I'm interested in feedback on.

The flushing of the per cpu pages only done when kmem_cache_shrink() is
run or when a slab cache is closed. And for diagnostics. So its rare and
not performance critical.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
