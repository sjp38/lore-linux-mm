Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id 0AA3C9003C7
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 16:14:10 -0400 (EDT)
Received: by ykcq64 with SMTP id q64so40299553ykc.2
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 13:14:09 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i70si2426581yke.58.2015.08.05.13.14.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Aug 2015 13:14:09 -0700 (PDT)
Date: Wed, 5 Aug 2015 13:14:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] zswap: change zpool/compressor at runtime
Message-Id: <20150805131406.8bd8a1a6d2a6691aa6eedd34@linux-foundation.org>
In-Reply-To: <1438782403-29496-4-git-send-email-ddstreet@ieee.org>
References: <1438782403-29496-1-git-send-email-ddstreet@ieee.org>
	<1438782403-29496-4-git-send-email-ddstreet@ieee.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Seth Jennings <sjennings@variantweb.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed,  5 Aug 2015 09:46:43 -0400 Dan Streetman <ddstreet@ieee.org> wrote:

> Update the zpool and compressor parameters to be changeable at runtime.
> When changed, a new pool is created with the requested zpool/compressor,
> and added as the current pool at the front of the pool list.  Previous
> pools remain in the list only to remove existing compressed pages from.
> The old pool(s) are removed once they become empty.
> 
> +/*********************************
> +* param callbacks
> +**********************************/
> +
> +static int __zswap_param_set(const char *val, const struct kernel_param *kp,
> +			     char *type, char *compressor)
> +{
> +	struct zswap_pool *pool, *put_pool = NULL;
> +	char str[kp->str->maxlen], *s;

What's the upper bound on the size of this variable-sized array?

> +	int ret;
> +
> +	strlcpy(str, val, kp->str->maxlen);
> +	s = strim(str);
> +
> +	/* if this is load-time (pre-init) param setting,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
