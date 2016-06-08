Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 36AE86B025F
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 10:11:06 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e189so14124621pfa.2
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 07:11:06 -0700 (PDT)
Received: from mail-pf0-x233.google.com (mail-pf0-x233.google.com. [2607:f8b0:400e:c00::233])
        by mx.google.com with ESMTPS id n85si1590684pfa.84.2016.06.08.07.11.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 07:11:05 -0700 (PDT)
Received: by mail-pf0-x233.google.com with SMTP id 62so3067017pfd.1
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 07:11:05 -0700 (PDT)
Date: Wed, 8 Jun 2016 23:10:58 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] mm/zsmalloc: add trace events for zs_compact
Message-ID: <20160608141058.GB498@swordfish>
References: <1465289804-4913-1-git-send-email-opensource.ganesh@gmail.com>
 <20160608001625.GB27258@bbox>
 <CADAEsF_wYQpMP_Hpr2LEnafxteV7aN1kCdAhLWhk13Ed1ueZ+A@mail.gmail.com>
 <20160608051352.GA28155@bbox>
 <CADAEsF_q0qzk2D_cKMCcvHxF7_eY1cQVKrBp0eM_v05jjOjSOA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADAEsF_q0qzk2D_cKMCcvHxF7_eY1cQVKrBp0eM_v05jjOjSOA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, rostedt@goodmis.org, mingo@redhat.com

Hello,

On (06/08/16 14:39), Ganesh Mahendran wrote:
> >> > On Tue, Jun 07, 2016 at 04:56:44PM +0800, Ganesh Mahendran wrote:
> >> >> Currently zsmalloc is widely used in android device.
> >> >> Sometimes, we want to see how frequently zs_compact is
> >> >> triggered or how may pages freed by zs_compact(), or which
> >> >> zsmalloc pool is compacted.
> >> >>
> >> >> Most of the time, user can get the brief information from
> >> >> trace_mm_shrink_slab_[start | end], but in some senario,
> >> >> they do not use zsmalloc shrinker, but trigger compaction manually.
> >> >> So add some trace events in zs_compact is convenient. Also we
> >> >> can add some zsmalloc specific information(pool name, total compact
> >> >> pages, etc) in zsmalloc trace.
> >> >
> >> > Sorry, I cannot understand what's the problem now and what you want to
> >> > solve. Could you elaborate it a bit?
> >> >
> >> > Thanks.
> >>
> >> We have backported the zs_compact() to our product(kernel 3.18).
> >> It is usefull for a longtime running device.
> >> But there is not a convenient way to get the detailed information
> >> of zs_comapct() which is usefull for  performance optimization.
> >> Information about how much time zs_compact used, which pool is
> >> compacted, how many page freed, etc.

sorry, couldn't check my email earlier.

zs_compact() is just one of the N sites that are getting called by
the shrinker; optimization here will "solve" only 1/N of the problems.
are there any trace events in any other shrinker callbacks?


why trace_mm_shrink_slab_start()/trace_mm_shrink_slab_end()/etc. don't work you?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
