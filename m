Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 3303B6B00A4
	for <linux-mm@kvack.org>; Fri, 29 May 2015 17:37:57 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so1123466pdb.2
        for <linux-mm@kvack.org>; Fri, 29 May 2015 14:37:56 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id xz3si10128004pab.181.2015.05.29.14.37.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 14:37:56 -0700 (PDT)
Date: Fri, 29 May 2015 14:37:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] zpool: add zpool_has_pool()
Message-Id: <20150529143755.35e070822d62cf39119aac13@linux-foundation.org>
In-Reply-To: <1432912338-16775-1-git-send-email-ddstreet@ieee.org>
References: <1432912338-16775-1-git-send-email-ddstreet@ieee.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Ganesh Mahendran <opensource.ganesh@gmail.com>, Minchan Kim <minchan@kernel.org>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 29 May 2015 11:12:18 -0400 Dan Streetman <ddstreet@ieee.org> wrote:

> Add zpool_has_pool() function, indicating if the specified type of zpool
> is available (i.e. zsmalloc or zbud).  This allows checking if a pool is
> available, without actually trying to allocate it, similar to
> crypto_has_alg().
> 
> ...
>
> +bool zpool_has_pool(char *type);

This has no callers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
