Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 801FE6B006C
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 06:18:34 -0400 (EDT)
Message-ID: <5045D4B9.9000909@parallels.com>
Date: Tue, 4 Sep 2012 14:15:21 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm, slob: Drop usage of page->private for storing
 page-sized allocations
References: <1346753637-13389-1-git-send-email-elezegarcia@gmail.com>
In-Reply-To: <1346753637-13389-1-git-send-email-elezegarcia@gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

On 09/04/2012 02:13 PM, Ezequiel Garcia wrote:
> This field was being used to store size allocation so it could be
> retrieved by ksize(). However, it is a bad practice to not mark a page
> as a slab page and then use fields for special purposes.
> There is no need to store the allocated size and
> ksize() can simply return PAGE_SIZE << compound_order(page).

What happens for allocations smaller than a page?
It seems you are breaking ksize for those.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
