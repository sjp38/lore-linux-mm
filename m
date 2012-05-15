Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 9D52C6B0081
	for <linux-mm@kvack.org>; Tue, 15 May 2012 16:36:55 -0400 (EDT)
Date: Tue, 15 May 2012 15:36:52 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: fix a memory leak in get_partial_node()
In-Reply-To: <1337108498-4104-1-git-send-email-js1304@gmail.com>
Message-ID: <alpine.DEB.2.00.1205151527150.11923@router.home>
References: <1337108498-4104-1-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org

On Wed, 16 May 2012, Joonsoo Kim wrote:

> In the case which is below,
>
> 1. acquire slab for cpu partial list
> 2. free object to it by remote cpu
> 3. page->freelist = t
>
> then memory leak is occurred.

Hmmm... Ok so we cannot assign page->freelist in get_partial_node() for
the cpu partial slabs. It must be done in the cmpxchg transition.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
