Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 78DAC6B0080
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 10:56:54 -0400 (EDT)
Date: Tue, 14 Aug 2012 14:56:53 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC/PATCH 2/2] mm, slob: Save real allocated size in
 page->private
In-Reply-To: <1344955130-29478-2-git-send-email-elezegarcia@gmail.com>
Message-ID: <0000013925a326f6-c47d16cb-5c67-4a28-ab5c-e0c3c9fbf610-000000@email.amazonses.com>
References: <1344955130-29478-1-git-send-email-elezegarcia@gmail.com> <1344955130-29478-2-git-send-email-elezegarcia@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@parallels.com>

On Tue, 14 Aug 2012, Ezequiel Garcia wrote:

> As documented in slob.c header, page->private field is used to return
> accurately the allocated size, through ksize().
> Therefore, if one allocates a contiguous set of pages the available size
> is PAGE_SIZE << order, instead of the requested size.

I would prefer if you would remove this strange feature from slob. The
ksize for a !PageSlab() "slab" page is always PAGE_SIZE << compound_order(page).
There is no need to use page->private here. It is a bad practice to not
mark a page as a slab page but then use fields for special purposes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
