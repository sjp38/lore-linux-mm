Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 4E7D46B0033
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 18:26:52 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id xb4so6131244pbc.36
        for <linux-mm@kvack.org>; Tue, 17 Sep 2013 15:26:51 -0700 (PDT)
Date: Tue, 17 Sep 2013 22:26:48 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/2] mm: fix slab.h endif comments
In-Reply-To: <5238A0FF.1040506@infradead.org>
Message-ID: <000001412e08751f-b416fc8e-6765-4aa9-b7f3-4ed9d377b6cc-000000@email.amazonses.com>
References: <5238A0FF.1040506@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Linux MM <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 17 Sep 2013, Randy Dunlap wrote:

> Add comments to several #endif lines to match most of the rest
> of the file (except for short, easily visible blocks).

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
