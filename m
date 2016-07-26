Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 857546B0262
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 21:55:47 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id u186so376208575ita.0
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 18:55:47 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTP id q80si2568999oic.269.2016.07.25.18.55.44
        for <linux-mm@kvack.org>;
        Mon, 25 Jul 2016 18:55:46 -0700 (PDT)
Message-ID: <5796BE82.4060903@huawei.com>
Date: Tue, 26 Jul 2016 09:36:02 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3] mem-hotplug: alloc new page from a nearest neighbor
 node when mem-offline
References: <5795E18B.5060302@huawei.com> <20160725135159.d8f06042d91a5b5d1e5c4ebf@linux-foundation.org>
In-Reply-To: <20160725135159.d8f06042d91a5b5d1e5c4ebf@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On 2016/7/26 4:51, Andrew Morton wrote:

> On Mon, 25 Jul 2016 17:53:15 +0800 Xishi Qiu <qiuxishi@huawei.com> wrote:
> 
>> Subject: [PATCH v3] mem-hotplug: alloc new page from a nearest neighbor node when mem-offline
> 
> argh.
> 
> This is "v3" but there is no v1 and no v2.  Please don't change the
> name of patches in this manner.  Or if you do, please be clear which
> patch is being updated.
> 
> I'll drop your
> mem-hotplug-use-different-mempolicy-in-alloc_migrate_target.patch.
> 

Hi Andrew,

Sorry for the confusion of title.

The following patches are all the old versions and please drop them all.

[PATCH] mem-hotplug: use GFP_HIGHUSER_MOVABLE and alloc from next node in alloc_migrate_target()
[PATCH 1/2] mem-hotplug: use GFP_HIGHUSER_MOVABLE in, alloc_migrate_target()
[PATCH 2/2] mem-hotplug: use different mempolicy in alloc_migrate_target()
[PATCH v2] mem-hotplug: alloc new page from the next node if zone is MOVABLE_ZONE

Thanks,
Xishi Qiu

> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
