Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id B91122802FE
	for <linux-mm@kvack.org>; Wed,  6 Sep 2017 13:22:12 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id m35so9454979qte.1
        for <linux-mm@kvack.org>; Wed, 06 Sep 2017 10:22:12 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r101sor190129qkr.148.2017.09.06.10.22.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Sep 2017 10:22:11 -0700 (PDT)
Date: Wed, 6 Sep 2017 10:22:08 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/1] workqueue: use type int instead of bool to index
 array
Message-ID: <20170906172208.GS1774378@devbig577.frc2.facebook.com>
References: <59AF6CB6.4090609@zoho.com>
 <20170906143320.GK1774378@devbig577.frc2.facebook.com>
 <c795e42f-8355-b79b-3239-15c4ea8fede7@zoho.com>
 <20170906164015.GQ1774378@devbig577.frc2.facebook.com>
 <58cb4eab-8334-a884-efa3-8752c34112e5@zoho.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <58cb4eab-8334-a884-efa3-8752c34112e5@zoho.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, jiangshanlai@gmail.com

On Thu, Sep 07, 2017 at 01:07:23AM +0800, zijun_hu wrote:
> in this case, i think type int is more suitable than bool in aspects of
> extendibility, program custom and consistency.

Please stop.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
