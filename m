Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1847A6B0361
	for <linux-mm@kvack.org>; Sat,  9 Sep 2017 11:35:24 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id i50so6418307qtf.0
        for <linux-mm@kvack.org>; Sat, 09 Sep 2017 08:35:24 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 26sor1483305qkr.150.2017.09.09.08.35.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 09 Sep 2017 08:35:23 -0700 (PDT)
Subject: Re: [PATCH v6 03/11] mm, x86: Add support for eXclusive Page Frame
 Ownership (XPFO)
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-4-tycho@docker.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <d4935027-aca6-f7a2-d15b-50b94484ecaf@redhat.com>
Date: Sat, 9 Sep 2017 08:35:17 -0700
MIME-Version: 1.0
In-Reply-To: <20170907173609.22696-4-tycho@docker.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, x86@kernel.org

On 09/07/2017 10:36 AM, Tycho Andersen wrote:
> +static inline struct xpfo *lookup_xpfo(struct page *page)
> +{
> +	struct page_ext *page_ext = lookup_page_ext(page);
> +
> +	if (unlikely(!page_ext)) {
> +		WARN(1, "xpfo: failed to get page ext");
> +		return NULL;
> +	}
> +
> +	return (void *)page_ext + page_xpfo_ops.offset;
> +}
> +

Just drop the WARN. On my arm64 UEFI machine this spews warnings
under most normal operation. This should be normal for some
situations but I haven't had the time to dig into why this
is so pronounced on arm64.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
