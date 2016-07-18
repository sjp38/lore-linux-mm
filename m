Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9E2366B0261
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 03:45:24 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r190so52433626wmr.0
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 00:45:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a72si13343625wma.76.2016.07.18.00.45.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Jul 2016 00:45:23 -0700 (PDT)
Subject: Re: [PATCH 1/2] mem-hotplug: use GFP_HIGHUSER_MOVABLE in,
 alloc_migrate_target()
References: <57884EAA.9030603@huawei.com>
 <20160718055150.GF9460@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f72b397d-3f62-d894-c582-5bf60e35d4d8@suse.cz>
Date: Mon, 18 Jul 2016 09:45:20 +0200
MIME-Version: 1.0
In-Reply-To: <20160718055150.GF9460@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Xishi Qiu <qiuxishi@huawei.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 07/18/2016 07:51 AM, Joonsoo Kim wrote:
> On Fri, Jul 15, 2016 at 10:47:06AM +0800, Xishi Qiu wrote:
>> alloc_migrate_target() is called from migrate_pages(), and the page
>> is always from user space, so we can add __GFP_HIGHMEM directly.
>
> No, all migratable pages are not from user space. For example,
> blockdev file cache has __GFP_MOVABLE and migratable but it has no
> __GFP_HIGHMEM and __GFP_USER.
>
> And, zram's memory isn't GFP_HIGHUSER_MOVABLE but has __GFP_MOVABLE.

Right, and there's also Minchan's series for arbitrary driver page 
migration...

> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
