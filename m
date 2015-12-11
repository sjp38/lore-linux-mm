Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 93E956B0253
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 18:43:22 -0500 (EST)
Received: by padhk6 with SMTP id hk6so32439204pad.2
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 15:43:22 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id rf10si4117959pab.94.2015.12.11.15.43.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Dec 2015 15:43:22 -0800 (PST)
Date: Fri, 11 Dec 2015 15:43:21 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/zswap: change incorrect strncmp use to strcmp
Message-Id: <20151211154321.e5b03afe8122d0f5afa38f4d@linux-foundation.org>
In-Reply-To: <1449876791-15962-1-git-send-email-ddstreet@ieee.org>
References: <1449876791-15962-1-git-send-email-ddstreet@ieee.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Weijie Yang <weijie.yang@samsung.com>, Seth Jennings <sjennings@variantweb.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 11 Dec 2015 18:33:11 -0500 Dan Streetman <ddstreet@ieee.org> wrote:

> Change the use of strncmp in zswap_pool_find_get() to strcmp.
> 
> The use of strncmp is no longer correct, now that zswap_zpool_type is
> not an array; sizeof() will return the size of a pointer, which isn't
> the right length to compare.

whoops

>  We don't need to use strncmp anyway,
> because the existing params and the passed in params are all guaranteed
> to be null terminated, so strcmp should be used.
> 

Thanks, I'll queue this for 4.4.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
