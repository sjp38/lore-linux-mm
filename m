Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f41.google.com (mail-bk0-f41.google.com [209.85.214.41])
	by kanga.kvack.org (Postfix) with ESMTP id 143676B0031
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 15:43:59 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id na10so658716bkb.14
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 12:43:59 -0800 (PST)
Received: from mail-bk0-x229.google.com (mail-bk0-x229.google.com [2a00:1450:4008:c01::229])
        by mx.google.com with ESMTPS id cq2si233005bkc.108.2014.01.23.12.43.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Jan 2014 12:43:59 -0800 (PST)
Received: by mail-bk0-f41.google.com with SMTP id na10so658708bkb.14
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 12:43:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140122123358.a65c42605513fc8466152801@linux-foundation.org>
References: <1387459407-29342-1-git-send-email-ddstreet@ieee.org>
 <20140114001115.GU1992@bbox> <CALZtONCCrckuHxgHB=GQj0tHszLAYTZZLGzFTnRkj9pvxx0dyg@mail.gmail.com>
 <20140115054208.GL1992@bbox> <CALZtONCehE8Td2C2w-fOC596uD54y1-kyc3SiKABBEODMb+a7Q@mail.gmail.com>
 <CALZtONAaPCi8eUhSmdXSxWbeFFN=ChsfL9OurSZUsSPo-_gnfg@mail.gmail.com> <20140122123358.a65c42605513fc8466152801@linux-foundation.org>
From: Dan Streetman <ddstreet@ieee.org>
Date: Thu, 23 Jan 2014 15:43:37 -0500
Message-ID: <CALZtONCteZPFaAG0oXQGnmDocnVmpmxBeGzYMa3B_4QpGSgCvw@mail.gmail.com>
Subject: Re: [PATCH] mm/zswap: add writethrough option
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Weijie Yang <weijie.yang@samsung.com>, Shirish Pargaonkar <spargaonkar@suse.com>, Mel Gorman <mgorman@suse.de>

On Wed, Jan 22, 2014 at 3:33 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 22 Jan 2014 09:19:58 -0500 Dan Streetman <ddstreet@ieee.org> wrote:
>
>> >>> > Acutally, I really don't know how much benefit we have that in-memory
>> >>> > swap overcomming to the real storage but if you want, zRAM with dm-cache
>> >>> > is another option rather than invent new wheel by "just having is better".
>> >>>
>> >>> I'm not sure if this patch is related to the zswap vs. zram discussions.  This
>> >>> only adds the option of using writethrough to zswap.  It's a first
>> >>> step to possibly
>> >>> making zswap work more efficiently using writeback and/or writethrough
>> >>> depending on
>> >>> the system and conditions.
>> >>
>> >> The patch size is small. Okay I don't want to be a party-pooper
>> >> but at least, I should say my thought for Andrew to help judging.
>> >
>> > Sure, I'm glad to have your suggestions.
>>
>> To give this a bump - Andrew do you have any concerns about this
>> patch?  Or can you pick this up?
>
> I don't pay much attention to new features during the merge window,
> preferring to shove them into a folder to look at later.  Often they
> have bitrotted by the time -rc1 comes around.
>
> I'm not sure that this review discussion has played out yet - is
> Minchan happy?

I think so, or at least ok enough to not block it, but please correct
me if I am wrong, Minchan.

>
> Please update the changelog so that it reflects the questions Minchan
> asked (any reviewer question should be regarded as an inadequacy in
> either the code commenting or the changelog - people shouldn't need to
> ask the programmer why he did something!) and resend for -rc1?

OK I'll update and resend.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
