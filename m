Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6C0096B0038
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 20:07:14 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id u5so578038408pgi.7
        for <linux-mm@kvack.org>; Thu, 29 Dec 2016 17:07:14 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id o12si55206888plg.84.2016.12.29.17.07.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Dec 2016 17:07:13 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id i5so20414931pgh.2
        for <linux-mm@kvack.org>; Thu, 29 Dec 2016 17:07:13 -0800 (PST)
Date: Fri, 30 Dec 2016 10:07:22 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: mm: fix typo of cache_alloc_zspage()
Message-ID: <20161230010722.GA2330@jagdpanzerIV.localdomain>
References: <58646FB7.2040502@huawei.com>
 <20161229064457.GD1815@bbox>
 <20161229065205.GA3892@jagdpanzerIV.localdomain>
 <20161229065935.GE1815@bbox>
 <20161229073403.GB3892@jagdpanzerIV.localdomain>
 <20161229075654.GF1815@bbox>
 <5864E6B3.2030106@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5864E6B3.2030106@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, ngupta@vflare.org, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

Hello,

On (12/29/16 18:34), Xishi Qiu wrote:
> Hi, Minchan and Sergey,
> 
> OK, but I will have a vacation soon, so could you just add
> that typo in your patch? or I will resend v3 several days later.

works for me. the patch is trivial, so I definitely can wait for v3.
if there is a chance to find additional trivial corrections/tweaks
then I wouldn't mind to include them into v3 as well. I just want
to keep the trivial patch flow at min level.

have a good vacation.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
