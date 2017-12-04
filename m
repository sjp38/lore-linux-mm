Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1C7B56B0069
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 11:42:46 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id n187so13523613pfn.10
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 08:42:46 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id y40si1411087pla.386.2017.12.04.08.42.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Dec 2017 08:42:45 -0800 (PST)
Date: Mon, 4 Dec 2017 08:42:40 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3 3/5] kasan: support alloca() poisoning
Message-ID: <20171204164240.GA24425@infradead.org>
References: <20171201213643.2506-1-paullawrence@google.com>
 <20171201213643.2506-4-paullawrence@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171201213643.2506-4-paullawrence@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Lawrence <paullawrence@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>, Greg Hackmann <ghackmann@google.com>

I don't think we are using alloca in kernel mode code, and we shouldn't.
What do I miss?  Is this hidden support for on-stack VLAs?  I thought
we'd get rid of them as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
