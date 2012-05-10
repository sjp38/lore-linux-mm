Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 4791D6B00F3
	for <linux-mm@kvack.org>; Thu, 10 May 2012 11:41:47 -0400 (EDT)
Date: Thu, 10 May 2012 10:41:44 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: fix a possible memory leak
In-Reply-To: <1336663979-2611-1-git-send-email-js1304@gmail.com>
Message-ID: <alpine.DEB.2.00.1205101041300.18664@router.home>
References: <1336663979-2611-1-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 11 May 2012, Joonsoo Kim wrote:

> Memory allocated by kstrdup should be freed,
> when kmalloc(kmem_size, GFP_KERNEL) is failed.

True.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
