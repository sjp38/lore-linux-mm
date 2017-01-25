Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DF6716B0033
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 23:02:13 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id d123so8166811pfd.0
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 20:02:13 -0800 (PST)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id x40si169714plb.112.2017.01.24.20.02.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Jan 2017 20:02:12 -0800 (PST)
Received: from epcas1p4.samsung.com (unknown [182.195.41.48])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0OKB00HPFHVM2U40@mailout1.samsung.com> for linux-mm@kvack.org;
 Wed, 25 Jan 2017 13:02:10 +0900 (KST)
Subject: Re: [Bug 192571] zswap + zram enabled BUG
From: Chulmin Kim <cmlaika.kim@samsung.com>
Message-id: <2059ec0c-d817-9660-9a16-59fe46f3e3a7@samsung.com>
Date: Tue, 24 Jan 2017 23:02:30 -0500
MIME-version: 1.0
In-reply-to: 
 <CALZtONAtjv1fjfVX2d5MKf2HY-kUtSDvA-m7pDbHW+ry2+OhAg@mail.gmail.com>
Content-type: text/plain; charset=utf-8; format=flowed
Content-transfer-encoding: 7bit
References: <bug-192571-27@https.bugzilla.kernel.org/>
 <bug-192571-27-qFfm1cXEv4@https.bugzilla.kernel.org/>
 <20170117122249.815342d95117c3f444acc952@linux-foundation.org>
 <20170118013948.GA580@jagdpanzerIV.localdomain>
 <1484719121.25232.1.camel@list.ru>
 <CALZtONBaJ0JJ+KBiRhRxh0=JWrfdVOsK_ThGE7hyyNPp2zFLrw@mail.gmail.com>
 <1485216185.5952.2.camel@list.ru>
 <CGME20170124201830epcas5p4aefd0bcb970be36f405d23c24e8cedbd@epcas5p4.samsung.com>
 <CALZtONAtjv1fjfVX2d5MKf2HY-kUtSDvA-m7pDbHW+ry2+OhAg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>, Alexandr <sss123next@list.ru>
Cc: bugzilla-daemon@bugzilla.kernel.org, Linux-MM <linux-mm@kvack.org>

On 01/24/2017 03:16 PM, Dan Streetman wrote:
> On Mon, Jan 23, 2017 at 7:03 PM, Alexandr <sss123next@list.ru> wrote:
>> -----BEGIN PGP SIGNED MESSAGE-----
>> Hash: SHA512
>>
>>
>>> Why would you do this?  There's no benefit of using zswap together
>>> with zram.
>>
>> i just wanted to test zram and zswap, i still not dig to deep in it,
>> but what i wanted is to use zram swap (with zswap disabled), and if it
>> exceeded use real swap on block device with zswap enabled.
>
> I don't believe that's possible, you can't enable zswap for only
> specific swap devices; and anyway, if you fill up zram, you won't
> really have any memory left for zswap to use will you?
>
> However, it shouldn't encounter any BUG(), like you saw.  If it's
> reproducable for you, can you give details on how to reproduce it?
>

Hello. Mr. Streetman.


Regarding to this problem, I have a question on zswap.

Is there any reason that
zswap_frontswap_load() does not call flush_dcache_page()?

The zswap load function can dirty the page mapped to user space (might 
be shareable/writable) which seems exactly the condition mentioned in 
the definition of flush_dcache_page().

I'm thinking that
flush_dcache_page() should be called in the end of zswap_frontswap_load().
Could you review my opinion?

Thanks!
Chulmin Kim








> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
