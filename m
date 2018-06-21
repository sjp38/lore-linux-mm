Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id EA9246B0007
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 03:16:16 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id g5-v6so878608pgv.12
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 00:16:16 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a16-v6si4248049pfk.350.2018.06.21.00.16.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 21 Jun 2018 00:16:15 -0700 (PDT)
Date: Thu, 21 Jun 2018 00:16:12 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: mempool: Remove unused argument in
 kasan_unpoison_element() and remove_element()
Message-ID: <20180621071612.GA584@bombadil.infradead.org>
References: <20180621070332.16633-1-baijiaju1990@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180621070332.16633-1-baijiaju1990@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia-Ju Bai <baijiaju1990@gmail.com>
Cc: akpm@linux-foundation.org, jthumshirn@suse.de, cl@linux.com, kstewart@linuxfoundation.org, pombredanne@nexb.com, gregkh@linuxfoundation.org, dvyukov@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jun 21, 2018 at 03:03:32PM +0800, Jia-Ju Bai wrote:
> The argument "gfp_t flags" is not used in kasan_unpoison_element() 
> and remove_element(), so remove it.
> 
> Signed-off-by: Jia-Ju Bai <baijiaju1990@gmail.com>

Reviewed-by: Matthew Wilcox <willy@infradead.org>
