Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 058D96B0032
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 10:49:49 -0400 (EDT)
Date: Fri, 2 Aug 2013 14:49:48 +0000
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] mm, slab_common: add 'unlikely' to size check of
 kmalloc_slab()
In-Reply-To: <1375408962-16743-1-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <000001403f81890d-57137aa9-0063-4457-8647-32369c68814f-000000@email.amazonses.com>
References: <1375408962-16743-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On Fri, 2 Aug 2013, Joonsoo Kim wrote:

> Size is usually below than KMALLOC_MAX_SIZE.
> If we add a 'unlikely' macro, compiler can make better code.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
