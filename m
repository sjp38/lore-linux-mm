Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B507F6B0069
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 23:06:31 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id d123so8251128pfd.0
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 20:06:31 -0800 (PST)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id f29si22002279pga.291.2017.01.24.20.06.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Jan 2017 20:06:30 -0800 (PST)
Received: from epcas1p4.samsung.com (unknown [182.195.41.48])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0OKB00DORI2SQD50@mailout1.samsung.com> for linux-mm@kvack.org;
 Wed, 25 Jan 2017 13:06:28 +0900 (KST)
Subject: Re: [PATCH v7 11/12] zsmalloc: page migration support
From: Chulmin Kim <cmlaika.kim@samsung.com>
Message-id: <7488422b-98d1-1198-70d5-47c1e2bac721@samsung.com>
Date: Tue, 24 Jan 2017 23:06:51 -0500
MIME-version: 1.0
In-reply-to: <20170123054034.GA12327@bbox>
Content-type: text/plain; charset=windows-1252; format=flowed
Content-transfer-encoding: 7bit
References: <1464736881-24886-1-git-send-email-minchan@kernel.org>
 <1464736881-24886-12-git-send-email-minchan@kernel.org>
 <CGME20170119001317epcas1p188357c77e1f4ff08b6d3dcb76dedca06@epcas1p1.samsung.com>
 <afd38699-f1c4-f63f-7362-29c514e9ffb4@samsung.com>
 <20170119024421.GA9367@bbox>
 <0a184bbf-0612-5f71-df68-c37500fa1eda@samsung.com>
 <20170119062158.GB9367@bbox>
 <e0e1fcae-d2c4-9068-afa0-b838d57d8dff@samsung.com>
 <20170123052244.GC11763@bbox> <20170123053056.GB2327@jagdpanzerIV.localdomain>
 <20170123054034.GA12327@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On 01/23/2017 12:40 AM, Minchan Kim wrote:
> On Mon, Jan 23, 2017 at 02:30:56PM +0900, Sergey Senozhatsky wrote:
>> On (01/23/17 14:22), Minchan Kim wrote:
>> [..]
>>>> Anyway, I will let you know the situation when it gets more clear.
>>>
>>> Yeb, Thanks.
>>>
>>> Perhaps, did you tried flush page before the writing?
>>> I think arm64 have no d-cache alising problem but worth to try it.
>>> Who knows :)
>>
>> I thought that flush_dcache_page() is only for cases when we write
>> to page (store that makes pages dirty), isn't it?
>
> I think we need both because to see recent stores done by the user.
> I'm not sure it should be done by block device driver rather than
> page cache. Anyway, brd added it so worth to try it, I thought. :)
>

Thanks for the suggestion!
It might be helpful
though proving it is not easy as the problem appears rarely.

Have you thought about
zram swap or zswap dealing with self modifying code pages (ex. JIT)?
(arm64 may have i-cache aliasing problem)

If it is problematic,
especiallly zswap (without flush_dcache_page in zswap_frontswap_load()) 
may provide the corrupted data
and even swap out (compressing) may see the corrupted data sooner or 
later, i guess.

THanks!





> Thanks.
>
> http://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/?id=c2572f2b4ffc27ba79211aceee3bef53a59bb5cd
>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
