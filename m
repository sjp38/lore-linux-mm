Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f170.google.com (mail-vc0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 4FADA6B0038
	for <linux-mm@kvack.org>; Sat, 27 Sep 2014 03:01:56 -0400 (EDT)
Received: by mail-vc0-f170.google.com with SMTP id ij19so7897571vcb.1
        for <linux-mm@kvack.org>; Sat, 27 Sep 2014 00:01:55 -0700 (PDT)
Received: from mail-vc0-x234.google.com (mail-vc0-x234.google.com [2607:f8b0:400c:c03::234])
        by mx.google.com with ESMTPS id w18si3266933vdj.103.2014.09.27.00.01.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 27 Sep 2014 00:01:54 -0700 (PDT)
Received: by mail-vc0-f180.google.com with SMTP id hq12so2786553vcb.11
        for <linux-mm@kvack.org>; Sat, 27 Sep 2014 00:01:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <542628C8.8030004@oracle.com>
References: <5420407E.8040406@oracle.com>
	<alpine.LSU.2.11.1409221531570.1244@eggly.anvils>
	<542628C8.8030004@oracle.com>
Date: Sat, 27 Sep 2014 11:01:54 +0400
Message-ID: <CAPAsAGyjq1YbvYneUe3GiYhfXy0bj1VjJehbN1Kkm70B=Y_wDQ@mail.gmail.com>
Subject: Re: mm: NULL ptr deref in migrate_page_move_mapping
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, Andrey Ryabinin <a.ryabinin@samsung.com>

2014-09-27 7:02 GMT+04:00 Sasha Levin <sasha.levin@oracle.com>:
> On 09/22/2014 07:04 PM, Hugh Dickins wrote:
>>> but I'm not sure what went wrong.
>> Most likely would be a zeroing of the radix_tree node, just as you
>> were experiencing zeroing of other mm structures in earlier weeks.
>>
>> Not that I've got any suggestions on where to take it from there.
>
> I've added poisoning to a few mm related structures, and managed to
> confirm that the issue here is indeed corruption rather than something
> specific with the given structures.
>
> Right now I'm looking into making KASan (Cc Andrey) to mark the poison
> bytes somehow so it would trigger an error on access, that way we'll
> know what's corruption them.
>
> Andrey, since it takes a while to trigger this corruption, could you
> confirm that if I kasan_poison_shadow() a few bytes I will get a KASan
> report on any read/write to them?
>

That's right. Note that poison value has to be negative.
Address and size of poisoned area has to be aligned to 8 bytes.

-- 
Best regards,
Andrey Ryabinin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
