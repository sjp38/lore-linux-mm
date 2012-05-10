Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 4084E6B00F4
	for <linux-mm@kvack.org>; Thu, 10 May 2012 11:27:53 -0400 (EDT)
Date: Thu, 10 May 2012 10:27:50 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: fix incorrect return type of get_any_partial()
In-Reply-To: <1336663436-2169-1-git-send-email-js1304@gmail.com>
Message-ID: <alpine.DEB.2.00.1205101027370.18664@router.home>
References: <alpine.DEB.2.00.1205080912590.25669@router.home> <1336663436-2169-1-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 11 May 2012, Joonsoo Kim wrote:

> Commit 497b66f2ecc97844493e6a147fd5a7e73f73f408 ('slub: return object pointer
> from get_partial() / new_slab().') changed return type of some functions.
> This updates missing part.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
