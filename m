Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 993286B0033
	for <linux-mm@kvack.org>; Sun, 17 Dec 2017 08:43:52 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id z109so2143445wrb.19
        for <linux-mm@kvack.org>; Sun, 17 Dec 2017 05:43:52 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m13sor6703876edi.53.2017.12.17.05.43.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 17 Dec 2017 05:43:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171216163226.GA1796@wolff.to>
References: <b1415a6d-fccd-31d0-ffa2-9b54fa699692@redhat.com>
 <20171214082452.GA16698@wolff.to> <20171214100927.GA26167@localhost.didichuxing.com>
 <20171214154136.GA12936@wolff.to> <CAA70yB6yofLz8pfhxXfq29sYqcGmBYLOvSruXi9XS_HM6mUrxg@mail.gmail.com>
 <20171215014417.GA17757@wolff.to> <CAA70yB6spi5c38kFVidRsJVaYc3W9tvpZz6wy+28rK7oeefQfw@mail.gmail.com>
 <20171215111050.GA30737@wolff.to> <CAA70yB66ekUGAvusQbqo7BLV+uBJtNz72cr+tZitsfjuVRWuXA@mail.gmail.com>
 <20171215195122.GA27126@wolff.to> <20171216163226.GA1796@wolff.to>
From: weiping zhang <zwp10758@gmail.com>
Date: Sun, 17 Dec 2017 21:43:50 +0800
Message-ID: <CAA70yB7wL_Wq5S8XQ9zHuLPDdwepv7dYdKALL8Sg0q6CNdAz5g@mail.gmail.com>
Subject: Re: Regression with a0747a859ef6 ("bdi: add error handle for bdi_debug_register")
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bruno Wolff III <bruno@wolff.to>
Cc: Laura Abbott <labbott@redhat.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, regressions@leemhuis.info, linux-block@vger.kernel.org

2017-12-17 0:32 GMT+08:00 Bruno Wolff III <bruno@wolff.to>:
> On Fri, Dec 15, 2017 at 13:51:22 -0600,
>  Bruno Wolff III <bruno@wolff.to> wrote:
>>
>>
>> I do not know what is different. Do you have any ideas? Most likely I
>> won't be able to test any more kernels until Monday (unless I can use most
>> of my most recent build over again very soon).
>
>
> The .config looks like it should be OK. I'll test setting loglevel on boot
> in case the default is different than what the config file says. I can't do
> that until Monday morning.
>
> I think it is more likely the the WARN_ON macro code isn't being compiled in
> for some reason. I haven't confirmed that, nor have I found anything that
> would leave that code out when I do a make, but include it during Fedora
> builds.
Hi, thanks for testing, I think you first reproduce this issue(got WARNING
at device_add_disk) by your own build, then add my debug patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
