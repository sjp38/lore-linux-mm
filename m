Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6D0786B0038
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 08:20:13 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id n13so5376493wmc.3
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 05:20:13 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c36sor12193564edf.49.2017.12.22.05.20.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Dec 2017 05:20:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171222045318.GA4505@wolff.to>
References: <20171221130057.GA26743@wolff.to> <CAA70yB6Z=r+zO7E+ZP74jXNk_XM2CggYthAD=TKOdBVsHLLV-w@mail.gmail.com>
 <20171221151843.GA453@wolff.to> <CAA70yB496Nuy2FM5idxLZthBwOVbhtsZ4VtXNJ_9mj2cvNC4kA@mail.gmail.com>
 <20171221153631.GA2300@wolff.to> <CAA70yB6nD7CiDZUpVPy7cGhi7ooQ5SPkrcXPDKqSYD2ezLrGHA@mail.gmail.com>
 <20171221164221.GA23680@wolff.to> <14f04d43-728a-953f-e07c-e7f9d5e3392d@kernel.dk>
 <20171221181531.GA21050@wolff.to> <20171221231603.GA15702@wolff.to> <20171222045318.GA4505@wolff.to>
From: weiping zhang <zwp10758@gmail.com>
Date: Fri, 22 Dec 2017 21:20:10 +0800
Message-ID: <CAA70yB5y1uLvtvEFLsE2C_ALLvSqEZ6XKA=zoPeSaH_eSAVL4w@mail.gmail.com>
Subject: Re: Regression with a0747a859ef6 ("bdi: add error handle for bdi_debug_register")
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bruno Wolff III <bruno@wolff.to>
Cc: Jens Axboe <axboe@kernel.dk>, Laura Abbott <labbott@redhat.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, regressions@leemhuis.info, weiping zhang <zhangweiping@didichuxing.com>, linux-block@vger.kernel.org

2017-12-22 12:53 GMT+08:00 Bruno Wolff III <bruno@wolff.to>:
> On Thu, Dec 21, 2017 at 17:16:03 -0600,
>  Bruno Wolff III <bruno@wolff.to> wrote:
>>
>>
>> Enforcing mode alone isn't enough as I tested that one one machine at home
>> and it didn't trigger the problem. I'll try another machine late tonight.
>
>
> I got the problem to occur on my i686 machine when booting in enforcing
> mode. This machine uses raid 1 vua mdraid which may or may not be a factor
> in this problem. The boot log has a trace at the end and might be helpful,
> so I'm attaching it here.
Hi Bruno,
I can reproduce this issue in my QEMU test VM easily, just add an soft
RAID1, always trigger
that warning, I'll debug it later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
