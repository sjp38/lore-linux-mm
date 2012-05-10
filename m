Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id C29BE6B00F3
	for <linux-mm@kvack.org>; Thu, 10 May 2012 11:56:37 -0400 (EDT)
Date: Thu, 10 May 2012 10:56:35 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: remove unused argument of init_kmem_cache_node()
In-Reply-To: <1336665047-22205-1-git-send-email-js1304@gmail.com>
Message-ID: <alpine.DEB.2.00.1205101055510.18664@router.home>
References: <1336665047-22205-1-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 11 May 2012, Joonsoo Kim wrote:

> We don't use the argument since commit 3b89d7d881a1dbb4da158f7eb5d6b3ceefc72810
> ('slub: move min_partial to struct kmem_cache'), so remove it

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
