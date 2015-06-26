Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id 986BC6B006C
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 21:43:15 -0400 (EDT)
Received: by oiax193 with SMTP id x193so65619693oia.2
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 18:43:15 -0700 (PDT)
Received: from mail-ob0-x233.google.com (mail-ob0-x233.google.com. [2607:f8b0:4003:c01::233])
        by mx.google.com with ESMTPS id my18si11249740obc.75.2015.06.25.18.43.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jun 2015 18:43:15 -0700 (PDT)
Received: by obbkm3 with SMTP id km3so58451936obb.1
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 18:43:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150626014248.GA26543@swordfish>
References: <CAA25o9SCnDYZ6vXWQWEWGDiwpV9rf+S_3Np8nJrWqHJ1x6-kMg@mail.gmail.com>
	<20150624152518.d3a5408f2bde405df1e6e5c4@linux-foundation.org>
	<CAA25o9RNLr4Gk_4m56bAf7_RBsObrccFWPtd-9jwuHg1NLdRTA@mail.gmail.com>
	<CAA25o9ShiKyPTBYbVooA=azb+XO9PWFtididoyPa4s-v56mvBg@mail.gmail.com>
	<20150626005808.GA5704@swordfish>
	<CAA25o9TCj0YSw1JhuPVsu9PzEMwnC2pLHNvNdMa+0OpJd1X64Q@mail.gmail.com>
	<20150626014248.GA26543@swordfish>
Date: Thu, 25 Jun 2015 18:43:14 -0700
Message-ID: <CAA25o9TON1MTgWjF5Qj05aTtx2RM_r9+FPzoYityZyuN3qssWA@mail.gmail.com>
Subject: Re: extremely long blockages when doing random writes to SSD
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

I will try and report, thanks.

On Thu, Jun 25, 2015 at 6:42 PM, Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com> wrote:
> On (06/25/15 18:31), Luigi Semenzato wrote:
>> We're using CFQ.
>>
>> CONFIG_DEFAULT_IOSCHED="cfq"
>> ...
>> CONFIG_IOSCHED_CFQ=y
>> CONFIG_IOSCHED_DEADLINE=y
>> CONFIG_IOSCHED_NOOP=y
>>
>
> any chance to try out DEADLINE?
> CFQ, as far as I understand, doesn't make too much sense for SSDs.
>
>         -ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
