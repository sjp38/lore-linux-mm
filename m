Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 6E2206B0255
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 06:10:43 -0400 (EDT)
Received: by padhk3 with SMTP id hk3so6114132pad.3
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 03:10:43 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id x6si10689173pas.27.2015.09.09.03.10.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Sep 2015 03:10:42 -0700 (PDT)
Subject: Re: [PATCH 1/2] lib: test_kasan: add some testcases
References: <1441771180-206648-1-git-send-email-long.wanglong@huawei.com>
 <1441771180-206648-2-git-send-email-long.wanglong@huawei.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <55F0059A.9040005@virtuozzo.com>
Date: Wed, 9 Sep 2015 13:10:34 +0300
MIME-Version: 1.0
In-Reply-To: <1441771180-206648-2-git-send-email-long.wanglong@huawei.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Long <long.wanglong@huawei.com>, ryabinin.a.a@gmail.com, adech.fo@gmail.com
Cc: akpm@linux-foundation.org, rusty@rustcorp.com.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, wanglong@laoqinren.net, peifeiyue@huawei.com, morgan.wang@huawei.com

On 09/09/2015 06:59 AM, Wang Long wrote:
> This patch add some out of bounds testcases to test_kasan
> module.
> 
> Signed-off-by: Wang Long <long.wanglong@huawei.com>

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
