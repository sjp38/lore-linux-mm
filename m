Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id AFDB46B0006
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 08:24:24 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id h33so6344781wrh.10
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 05:24:24 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id i3si4736343wrb.229.2018.03.02.05.24.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Mar 2018 05:24:23 -0800 (PST)
Subject: Re: [Question PATCH 0/1] mm: crash in vmalloc_to_page - misuse or
 bug?
References: <20180222141324.5696-1-igor.stoppa@huawei.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <921e8bb3-3c4d-be75-3029-35fde00087c7@huawei.com>
Date: Fri, 2 Mar 2018 15:23:45 +0200
MIME-Version: 1.0
In-Reply-To: <20180222141324.5696-1-igor.stoppa@huawei.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: willy@infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Ping?

The kernel test automation seems to confirm my findings:

https://marc.info/?l=linux-mm&m=151999308428656&w=2

Is this really a bug?

On 22/02/18 16:13, Igor Stoppa wrote:
> While trying to change the code of find_vm_area, I got an automated
> notification that my code was breaking the testing of i386, based on the
> 0-day testing automation from 01.org
> 
> I started investigating the issue and noticed that it seems to be
> reproducible also on top of plain 4.16-rc2, without any of my patches.
> 
> I'm still not 100% sure that I'm doing something sane, but I thought it
> might be good to share the finding.
> 
> The patch contains both a minimal change, to trigger the crash, and a
> snippet of the log of the crash i get.
> 
> Igor Stoppa (1):
>   crash vmalloc_to_page()
> 
>  mm/vmalloc.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)


--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
