Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6A6F960044A
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 04:59:32 -0500 (EST)
Received: by pwi1 with SMTP id 1so7936691pwi.6
        for <linux-mm@kvack.org>; Mon, 28 Dec 2009 01:59:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091228144302.864f2e97.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091228134619.92ba28f6.minchan.kim@barrios-desktop>
	 <20091228134752.44d13c34.kamezawa.hiroyu@jp.fujitsu.com>
	 <20091228143154.ec0431b5.minchan.kim@barrios-desktop>
	 <20091228144302.864f2e97.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 28 Dec 2009 18:59:30 +0900
Message-ID: <28c262360912280159r69612770j97e30c3948c88c92@mail.gmail.com>
Subject: Re: [PATCH -mmotm-2009-12-10-17-19] Fix wrong rss count of smaps
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Matt Mackall <mpm@selenic.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Mon, Dec 28, 2009 at 2:43 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 28 Dec 2009 14:31:54 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>>
>> > BTW, how about counting ZERO page in smaps? Ignoring them completely sounds
>> > not very good.
>>
>> I am not use it is useful.
>>
>> zero page snapshot of ongoing process is useful?
>> Doesn't Admin need to know about zero page?
>> Let's admins use it well. If we remove zero page again?
>> How many are applications use smaps?
>> Did we have a problem without it?
>>
> My concern is that hiding indormation which was exported before.
> No more than that and no strong demand.
>
>
>> When I think of it, there are too many qeustions.
>> Most important thing to add new statistics is just need of customer.
>>
>> Frankly speaking, I don't have good scenario of using zero page.
>> Do you have any scenario it is valueable?
>>
> read before write ? maybe sometimes happens.
>
> For example. current glibc's calloc() avoids memset() if the pages are
> dropped by MADVISE (without unmap).
>
> Before starting zero-page works, I checked "questions" in lkml and
> found some reports that some applications start to go OOM after zero-page
> removal.
>
> For me, I know one of my customer's application depends on behavior of
> zero page (on RHEL5). So, I tried to add again it before RHEL6 because
> I think removal of zero-page corrupts compatibility.
>

Okay. I will repost the patch.

> Thanks,
> -Kame
>
>



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
