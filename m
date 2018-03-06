Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 62B896B0005
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 13:45:13 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id bb5-v6so626308plb.22
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 10:45:13 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n3si12343892pfi.302.2018.03.06.10.45.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Mar 2018 10:45:12 -0800 (PST)
Date: Tue, 6 Mar 2018 10:45:08 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 12/25] slub: make ->reserved unsigned int
Message-ID: <20180306184508.GA11216@bombadil.infradead.org>
References: <20180305200730.15812-1-adobriyan@gmail.com>
 <20180305200730.15812-12-adobriyan@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180305200730.15812-12-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org

On Mon, Mar 05, 2018 at 11:07:17PM +0300, Alexey Dobriyan wrote:
> ->reserved is either 0 or sizeof(struct rcu_head), can't be negative.

Maybe make it unsigned char instead of unsigned int in case there's
anything else that could use the space?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
