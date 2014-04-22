Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8999F6B0035
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 09:44:18 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id k14so3872692wgh.11
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 06:44:17 -0700 (PDT)
Received: from mail-we0-x232.google.com (mail-we0-x232.google.com [2a00:1450:400c:c03::232])
        by mx.google.com with ESMTPS id fs8si5291219wib.51.2014.04.22.06.44.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 06:44:17 -0700 (PDT)
Received: by mail-we0-f178.google.com with SMTP id u56so5050425wes.9
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 06:44:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140422100505.GB937@swordfish.minsk.epam.com>
References: <1397922764-1512-1-git-send-email-ddstreet@ieee.org>
 <1397922764-1512-4-git-send-email-ddstreet@ieee.org> <20140422100505.GB937@swordfish.minsk.epam.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Tue, 22 Apr 2014 09:43:56 -0400
Message-ID: <CALZtONDk0UOBwUNGppDCW0fk2kGtAdwoKq6mmWTOO5nihatdwQ@mail.gmail.com>
Subject: Re: [PATCH 3/4] mm: zpool: implement common zpool api to zbud/zsmalloc
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Weijie Yang <weijie.yang@samsung.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Tue, Apr 22, 2014 at 6:05 AM, Sergey Senozhatsky
<sergey.senozhatsky@gmail.com> wrote:
> Hello,
>> diff --git a/mm/Makefile b/mm/Makefile
>> index 60cacbb..4135f7c 100644
>> --- a/mm/Makefile
>> +++ b/mm/Makefile
>> @@ -60,6 +60,7 @@ obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
>>  obj-$(CONFIG_CLEANCACHE) += cleancache.o
>>  obj-$(CONFIG_MEMORY_ISOLATION) += page_isolation.o
>>  obj-$(CONFIG_PAGE_OWNER) += pageowner.o
>> +obj-$(CONFIG_ZPOOL)  += zpool.o
>
> side note, this fails to apply on linux-next. mm/Makefile does not contain
> CONFIG_PAGE_OWNER
>
> https://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/tree/mm/Makefile?id=refs/tags/next-20140422
>
> what tree this patchset is against of?

It's against this mmotm tree:
git://git.cmpxchg.org/linux-mmotm.git

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
