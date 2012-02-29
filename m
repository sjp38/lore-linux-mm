Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id DE4EF6B004A
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 10:24:33 -0500 (EST)
Date: Wed, 29 Feb 2012 09:24:30 -0600 (CST)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH -next] slub: set PG_slab on all of slab pages
In-Reply-To: <1330505674-31610-1-git-send-email-namhyung.kim@lge.com>
Message-ID: <alpine.DEB.2.00.1202290922210.32268@router.home>
References: <1330505674-31610-1-git-send-email-namhyung.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Namhyung Kim <namhyung@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 29 Feb 2012, Namhyung Kim wrote:

> Unlike SLAB, SLUB doesn't set PG_slab on tail pages, so if a user would
> call free_pages() incorrectly on a object in a tail page, she will get
> confused with the undefined result. Setting the flag would help her by
> emitting a warning on bad_page() in such a case.

NAK

You cannot free a tail page of a compound higher order page independently.
You must free the whole compound.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
