Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 311176B0038
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 09:01:36 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r63so3909328wmb.9
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 06:01:36 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q6sor10788448edb.27.2017.12.21.06.01.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Dec 2017 06:01:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171221130057.GA26743@wolff.to>
References: <b1415a6d-fccd-31d0-ffa2-9b54fa699692@redhat.com> <20171221130057.GA26743@wolff.to>
From: weiping zhang <zwp10758@gmail.com>
Date: Thu, 21 Dec 2017 22:01:33 +0800
Message-ID: <CAA70yB6Z=r+zO7E+ZP74jXNk_XM2CggYthAD=TKOdBVsHLLV-w@mail.gmail.com>
Subject: Re: Regression with a0747a859ef6 ("bdi: add error handle for bdi_debug_register")
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bruno Wolff III <bruno@wolff.to>
Cc: Laura Abbott <labbott@redhat.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, regressions@leemhuis.info, weiping zhang <zhangweiping@didichuxing.com>, linux-block@vger.kernel.org

2017-12-21 21:00 GMT+08:00 Bruno Wolff III <bruno@wolff.to>:
> After today, I won't have physical access to the problem machine until
> January 2nd. So if you guys have any testing suggestions I need them soon if
> they are to get done before my vacation.
> I do plan to try booting to level 1 to see if I can get a login prompt that
> might facilitate testing. The lockups do happen fairly late in the boot
> process. I never get to X, but maybe it will get far enough for a console
> login.
>
Hi,
how do you do bisect ?build all kernel commit one by one ?
as you did before:
https://bugzilla.redhat.com/show_bug.cgi?id=1520982

what kernel source code do you use that occur warning at device_add_disk?
from fedora or any official release ? if so ,could you provide web link?

if you use same kernel source code and same .config, why your own build
Cann't trigger that warning ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
