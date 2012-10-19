Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id C6A256B0069
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 10:09:11 -0400 (EDT)
Date: Fri, 19 Oct 2012 14:09:10 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 3/3] mm/sl[aou]b: Move common kmem_cache_size() to
 slab.h
In-Reply-To: <1350649992-25988-3-git-send-email-elezegarcia@gmail.com>
Message-ID: <0000013a795b30e8-b172d712-6376-4b9a-9fea-1dd04669b35c-000000@email.amazonses.com>
References: <1350649992-25988-1-git-send-email-elezegarcia@gmail.com> <1350649992-25988-3-git-send-email-elezegarcia@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Bird <tim.bird@am.sony.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

On Fri, 19 Oct 2012, Ezequiel Garcia wrote:

> This function is identically defined in all three allocators
> and it's trivial to move it to slab.h
>
> Since now it's static, inline, header-defined function
> this patch also drops the EXPORT_SYMBOL tag.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
