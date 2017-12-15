Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6C0226B0069
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 21:04:34 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id l4so4190034wre.10
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 18:04:34 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e24sor3788587edc.17.2017.12.14.18.04.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Dec 2017 18:04:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171215014417.GA17757@wolff.to>
References: <b1415a6d-fccd-31d0-ffa2-9b54fa699692@redhat.com>
 <20171214082452.GA16698@wolff.to> <20171214100927.GA26167@localhost.didichuxing.com>
 <20171214154136.GA12936@wolff.to> <CAA70yB6yofLz8pfhxXfq29sYqcGmBYLOvSruXi9XS_HM6mUrxg@mail.gmail.com>
 <20171215014417.GA17757@wolff.to>
From: weiping zhang <zwp10758@gmail.com>
Date: Fri, 15 Dec 2017 10:04:32 +0800
Message-ID: <CAA70yB6spi5c38kFVidRsJVaYc3W9tvpZz6wy+28rK7oeefQfw@mail.gmail.com>
Subject: Re: Regression with a0747a859ef6 ("bdi: add error handle for bdi_debug_register")
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bruno Wolff III <bruno@wolff.to>
Cc: Laura Abbott <labbott@redhat.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, regressions@leemhuis.info, linux-block@vger.kernel.org

2017-12-15 9:44 GMT+08:00 Bruno Wolff III <bruno@wolff.to>:
> On Fri, Dec 15, 2017 at 09:22:21 +0800,
>  weiping zhang <zwp10758@gmail.com> wrote:
>>
>>
>> Thanks your testing, but I cann't find WARN_ON in device_add_disk from
>> this boot1.log, could you help reproduce that issue? And does this issue
>> can be
>> triggered at every bootup ?
>
>
> I don't know what you need for the first question. When I am physically at
> the machine I can do test reboots. If you have something specific you want
> me to try I should be able to.
>
> Every time I boot with the problem commit, the boot never completes. However
> it does seem to get pretty far. I get multiple register dumps every time.
> After a while (a few minutes) I reboot to a wrking kernel.
>
> The output I included is from: journalctl -k -b -1
> If you think it would be better to see more than dmesg output let me know.
I just want to know WARN_ON WHAT in device_add_disk,
if bdi_register_owner return error code, it may fail at any step of following:

bdi_debug_root is NULL
bdi->debug_dir is NULL
bdi->debug_stats is NULL

so I want see the WARN_ON as you paste before, also my DEBUG log will help
to find which step fail.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
