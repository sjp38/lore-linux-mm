Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1D3966B025F
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 04:31:00 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id c82so38848288wme.2
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 01:31:00 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id t124si3589102wmb.85.2016.06.17.01.30.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 01:30:59 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id r201so2686659wme.0
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 01:30:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160615231732.GJ17127@bbox>
References: <cover.1466000844.git.geliangtang@gmail.com> <efcf047e747d9d1e80af16ebfc51ea1964a7a621.1466000844.git.geliangtang@gmail.com>
 <20160615231732.GJ17127@bbox>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Fri, 17 Jun 2016 10:30:58 +0200
Message-ID: <CAMJBoFPcaAbsQ=PA2WPsmuyd1a-SyJgE5k4Rn2CUf6rS0-ykKw@mail.gmail.com>
Subject: Re: [PATCH] zram: update zram to use zpool
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Geliang Tang <geliangtang@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Dan Streetman <ddstreet@ieee.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

Hi Minchan,

On Thu, Jun 16, 2016 at 1:17 AM, Minchan Kim <minchan@kernel.org> wrote:
> On Wed, Jun 15, 2016 at 10:42:07PM +0800, Geliang Tang wrote:
>> Change zram to use the zpool api instead of directly using zsmalloc.
>> The zpool api doesn't have zs_compact() and zs_pool_stats() functions.
>> I did the following two things to fix it.
>> 1) I replace zs_compact() with zpool_shrink(), use zpool_shrink() to
>>    call zs_compact() in zsmalloc.
>> 2) The 'pages_compacted' attribute is showed in zram by calling
>>    zs_pool_stats(). So in order not to call zs_pool_state() I move the
>>    attribute to zsmalloc.
>>
>> Signed-off-by: Geliang Tang <geliangtang@gmail.com>
>
> NACK.
>
> I already explained why.
> http://lkml.kernel.org/r/20160609013411.GA29779@bbox

This is a fair statement, to a certain extent. I'll let Geliang speak
for himself but I am personally interested in this zram extension
because I want it to work on MMU-less systems. zsmalloc can not handle
that, so I want to be able to use zram over z3fold.

Best regards,
   Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
