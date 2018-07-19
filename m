Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0E1A66B000E
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 12:27:57 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id x204-v6so6937987qka.6
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 09:27:57 -0700 (PDT)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10123.outbound.protection.outlook.com. [40.107.1.123])
        by mx.google.com with ESMTPS id x6-v6si1142332qth.304.2018.07.19.09.27.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 19 Jul 2018 09:27:56 -0700 (PDT)
Subject: Re: [PATCH] mm: Cleanup in do_shrink_slab()
References: <153201627722.12295.11034132843390627757.stgit@localhost.localdomain>
 <0f98d9b38be1466b8608d5c071aa52ed@AcuMS.aculab.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <bdfb596f-8658-3ca4-7b6f-bd749466097d@virtuozzo.com>
Date: Thu, 19 Jul 2018 19:27:48 +0300
MIME-Version: 1.0
In-Reply-To: <0f98d9b38be1466b8608d5c071aa52ed@AcuMS.aculab.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Laight <David.Laight@ACULAB.COM>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "vdavydov.dev@gmail.com" <vdavydov.dev@gmail.com>, "mhocko@suse.com" <mhocko@suse.com>, "penguin-kernel@I-love.SAKURA.ne.jp" <penguin-kernel@I-love.SAKURA.ne.jp>, "shakeelb@google.com" <shakeelb@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 19.07.2018 19:21, David Laight wrote:
> From: Kirill Tkhai
>> Sent: 19 July 2018 17:05
>>
>> Group long variables together to minimize number of occupied lines
>> and place all definitions in back Christmas tree order.
> 
> Grouping together unrelated variables doesn't really make the code
> any more readable.
> IMHO One variable per line is usually best.

>> Also, simplify expression around batch_size: use all power of C language!
> 
>    foo = bar ? : baz;
> Is not part of C, it is a gcc extension.

Then, use all power of GNU extensions.
