Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id DABE16B0011
	for <linux-mm@kvack.org>; Fri,  6 May 2011 14:56:58 -0400 (EDT)
Date: Fri, 6 May 2011 13:56:52 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: slub_def.h: needs additional check for "index"
In-Reply-To: <BANLkTi=Jdxu7am8-jhJbT0t-uhNmW4zWhw@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1105061355020.5832@router.home>
References: <BANLkTi=Jdxu7am8-jhJbT0t-uhNmW4zWhw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxin John <maxin.john@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 6 May 2011, Maxin John wrote:

> In slub_def.h file, the kmalloc_index() may return -1 for some special cases.
> If that negative return value gets assigned to "index", it might lead to issues
> later as the variable "index" is used as index to array "kmalloc_caches" in :


The value passed to kmalloc_slab is tested before the result is used.
kmalloc_slab() only returns -1 for values > 4MB.

The size of the object is checked against SLUB_MAX size which is
significantly smaller than 4MB. 8kb by default.

So kmalloc_slab() cannot return -1 if the parameter is checked first.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
