Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 29BEC6B0069
	for <linux-mm@kvack.org>; Sun, 26 Oct 2014 21:23:48 -0400 (EDT)
Received: by mail-ig0-f169.google.com with SMTP id uq10so4984015igb.0
        for <linux-mm@kvack.org>; Sun, 26 Oct 2014 18:23:47 -0700 (PDT)
Received: from mail-ig0-x236.google.com (mail-ig0-x236.google.com. [2607:f8b0:4001:c05::236])
        by mx.google.com with ESMTPS id ih15si10529611igb.60.2014.10.26.18.23.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 26 Oct 2014 18:23:47 -0700 (PDT)
Received: by mail-ig0-f182.google.com with SMTP id hn18so4855081igb.15
        for <linux-mm@kvack.org>; Sun, 26 Oct 2014 18:23:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20141026014143.GA3328@gmail.com>
References: <000001cff035$c060dc60$41229520$%yang@samsung.com>
	<20141026014143.GA3328@gmail.com>
Date: Mon, 27 Oct 2014 09:23:46 +0800
Message-ID: <CAL1ERfM-w-pDsL+SSEwnPSmkXWeRGBDeQjMoc5wfSqC4zfneFg@mail.gmail.com>
Subject: Re: [PATCH 1/2] zram: make max_used_pages reset work correctly
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Weijie Yang <weijie.yang@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Streetman <ddstreet@ieee.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Sun, Oct 26, 2014 at 9:41 AM, Minchan Kim <minchan@kernel.org> wrote:
> Hello,
>
> On Sat, Oct 25, 2014 at 05:25:11PM +0800, Weijie Yang wrote:
>> The commit 461a8eee6a ("zram: report maximum used memory") introduces a new
>> knob "mem_used_max" in zram.stats sysfs, and wants to reset it via write 0
>> to the sysfs interface.
>>
>> However, the current code cann't reset it correctly, so let's fix it.
>
> We wanted to reset it to current used total memory, not 0.

I misread taht, I will resend the 2/2 patch

> --
> Kind regards,
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
