Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 583156B0033
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 02:13:27 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id d134so192040813pfd.0
        for <linux-mm@kvack.org>; Sun, 22 Jan 2017 23:13:27 -0800 (PST)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id c23si14800560pli.184.2017.01.22.23.13.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Jan 2017 23:13:26 -0800 (PST)
Received: by mail-pg0-x241.google.com with SMTP id 75so12985868pgf.3
        for <linux-mm@kvack.org>; Sun, 22 Jan 2017 23:13:26 -0800 (PST)
Date: Mon, 23 Jan 2017 16:13:39 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm: extend zero pages to same element pages for zram
Message-ID: <20170123071339.GD2327@jagdpanzerIV.localdomain>
References: <1483692145-75357-1-git-send-email-zhouxianrong@huawei.com>
 <1484296195-99771-1-git-send-email-zhouxianrong@huawei.com>
 <20170121084338.GA405@jagdpanzerIV.localdomain>
 <84073d07-6939-b22d-8bda-4fa2a9127555@huawei.com>
 <20170123025826.GA24581@js1304-P5Q-DELUXE>
 <20170123040347.GA2327@jagdpanzerIV.localdomain>
 <20170123062716.GF24581@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170123062716.GF24581@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, zhouxianrong <zhouxianrong@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, minchan@kernel.org, ngupta@vflare.org, Mi.Sophia.Wang@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com

On (01/23/17 15:27), Joonsoo Kim wrote:
> Hello,
> 
> Think about following case in 64 bits kernel.
> 
> If value pattern in the page is like as following, we cannot detect
> the same page with 'unsigned int' element.
> 
> AAAAAAAABBBBBBBBAAAAAAAABBBBBBBB...
> 
> 4 bytes is 0xAAAAAAAA and next 4 bytes is 0xBBBBBBBB and so on.

yep, that's exactly the case that I though would be broken
with a 4-bytes pattern matching. so my conlusion was that
for 4 byte pattern we would have working detection anyway,
for 8 bytes patterns we might have some extra matching.
not sure if it matters that much though.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
