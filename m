Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id DF94C6B0038
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 09:02:22 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id v184so10341876wmf.1
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 06:02:22 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p55sor4485533edc.47.2017.12.15.06.02.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Dec 2017 06:02:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171215111050.GA30737@wolff.to>
References: <b1415a6d-fccd-31d0-ffa2-9b54fa699692@redhat.com>
 <20171214082452.GA16698@wolff.to> <20171214100927.GA26167@localhost.didichuxing.com>
 <20171214154136.GA12936@wolff.to> <CAA70yB6yofLz8pfhxXfq29sYqcGmBYLOvSruXi9XS_HM6mUrxg@mail.gmail.com>
 <20171215014417.GA17757@wolff.to> <CAA70yB6spi5c38kFVidRsJVaYc3W9tvpZz6wy+28rK7oeefQfw@mail.gmail.com>
 <20171215111050.GA30737@wolff.to>
From: weiping zhang <zwp10758@gmail.com>
Date: Fri, 15 Dec 2017 22:02:20 +0800
Message-ID: <CAA70yB66ekUGAvusQbqo7BLV+uBJtNz72cr+tZitsfjuVRWuXA@mail.gmail.com>
Subject: Re: Regression with a0747a859ef6 ("bdi: add error handle for bdi_debug_register")
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bruno Wolff III <bruno@wolff.to>
Cc: Laura Abbott <labbott@redhat.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, regressions@leemhuis.info, linux-block@vger.kernel.org

2017-12-15 19:10 GMT+08:00 Bruno Wolff III <bruno@wolff.to>:
> On Fri, Dec 15, 2017 at 10:04:32 +0800,
>  weiping zhang <zwp10758@gmail.com> wrote:
>>
>> I just want to know WARN_ON WHAT in device_add_disk,
>> if bdi_register_owner return error code, it may fail at any step of
>> following:
>
>
> Was that output in the original boot log? I didn't see anything there that
> had the string WARN_ON. The first log was from a Fedora kernel. The second
Sorry to let you confuse, WARN_ON means we catch log as following:
WARNING: CPU: 3 PID: 3486 at block/genhd.c:680 device_add_disk+0x3d9/0x460

> from a kernel I built. I used a Fedora config though. The config was
> probably from one of their nodebug kernels, I could build another one using
> a config from a debug kernel. Would that likely provide what you are looking
> for?

Yes, please help reproduce this issue include my debug patch. Reproduce means
we can see WARN_ON in device_add_disk caused by failure of bdi_register_owner.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
