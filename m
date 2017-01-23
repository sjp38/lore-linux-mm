Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id B32D96B0033
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 01:26:26 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id x49so95196822qtc.7
        for <linux-mm@kvack.org>; Sun, 22 Jan 2017 22:26:26 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 18si10140889qkm.20.2017.01.22.22.26.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Jan 2017 22:26:26 -0800 (PST)
Date: Sun, 22 Jan 2017 22:26:21 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: extend zero pages to same element pages for zram
Message-ID: <20170123062621.GB12833@bombadil.infradead.org>
References: <1483692145-75357-1-git-send-email-zhouxianrong@huawei.com>
 <1484296195-99771-1-git-send-email-zhouxianrong@huawei.com>
 <20170121084338.GA405@jagdpanzerIV.localdomain>
 <84073d07-6939-b22d-8bda-4fa2a9127555@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84073d07-6939-b22d-8bda-4fa2a9127555@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhouxianrong <zhouxianrong@huawei.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, minchan@kernel.org, ngupta@vflare.org, Mi.Sophia.Wang@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com

On Sun, Jan 22, 2017 at 10:58:38AM +0800, zhouxianrong wrote:
> 1. memset is just set a int value but i want to set a long value.

memset doesn't set an int value.

DESCRIPTION
       The  memset()  function  fills  the  first  n  bytes of the memory area
       pointed to by s with the constant byte c.

It sets a byte value.  K&R just happened to choose 'int' as the type
to store that "unsigned char" in.  Probably for very good reasons which
make absolutely no sense today.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
