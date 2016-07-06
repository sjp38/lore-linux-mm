Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9FC60828E1
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 02:20:08 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id a4so151764854lfa.1
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 23:20:08 -0700 (PDT)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id t4si280722wma.107.2016.07.05.23.20.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jul 2016 23:20:07 -0700 (PDT)
Received: by mail-wm0-x22c.google.com with SMTP id z126so99016436wme.0
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 23:20:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160706023232.GB13566@bbox>
References: <1467614999-4326-1-git-send-email-opensource.ganesh@gmail.com> <20160706023232.GB13566@bbox>
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Date: Wed, 6 Jul 2016 14:20:05 +0800
Message-ID: <CADAEsF8hTsbcfQ8vBOhL=NZM2WdjY6Vfq9qs6BQTBf2P7pqxoQ@mail.gmail.com>
Subject: Re: [PATCH v2 1/8] mm/zsmalloc: modify zs compact trace interface
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, rostedt@goodmis.org, mingo@redhat.com

2016-07-06 10:32 GMT+08:00 Minchan Kim <minchan@kernel.org>:
> Hi Ganesh,
>
> On Mon, Jul 04, 2016 at 02:49:52PM +0800, Ganesh Mahendran wrote:
>> This patch changes trace_zsmalloc_compact_start[end] to
>> trace_zs_compact_start[end] to keep function naming consistent
>> with others in zsmalloc
>>
>> Also this patch remove pages_total_compacted information which
>> may not really needed.
>>
>> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
>
> Once we decide to add event trace, I prefer getting more detailed
> information which is hard to get it via /sys/block/zram/.
> So, we can add trace __zs_compact as well as zs_compact with
> some changes.
>
> IOW,
>
> zs_compact
>         trace_zs_compact_start(pool->name)
>         __zs_compact
>                 trace_zs_compact(class, scanned_obj, freed_pages)
>         trace_zs_compact_end(pool->name)

Thanks, I will do it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
