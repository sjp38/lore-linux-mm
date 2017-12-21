Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B8ABB6B026A
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 10:48:21 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id o16so4206722wmf.4
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 07:48:21 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k2sor10906242edc.21.2017.12.21.07.48.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Dec 2017 07:48:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171221153631.GA2300@wolff.to>
References: <b1415a6d-fccd-31d0-ffa2-9b54fa699692@redhat.com>
 <20171221130057.GA26743@wolff.to> <CAA70yB6Z=r+zO7E+ZP74jXNk_XM2CggYthAD=TKOdBVsHLLV-w@mail.gmail.com>
 <20171221151843.GA453@wolff.to> <CAA70yB496Nuy2FM5idxLZthBwOVbhtsZ4VtXNJ_9mj2cvNC4kA@mail.gmail.com>
 <20171221153631.GA2300@wolff.to>
From: weiping zhang <zwp10758@gmail.com>
Date: Thu, 21 Dec 2017 23:48:19 +0800
Message-ID: <CAA70yB6nD7CiDZUpVPy7cGhi7ooQ5SPkrcXPDKqSYD2ezLrGHA@mail.gmail.com>
Subject: Re: Regression with a0747a859ef6 ("bdi: add error handle for bdi_debug_register")
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bruno Wolff III <bruno@wolff.to>
Cc: Laura Abbott <labbott@redhat.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, regressions@leemhuis.info, weiping zhang <zhangweiping@didichuxing.com>, linux-block@vger.kernel.org

2017-12-21 23:36 GMT+08:00 Bruno Wolff III <bruno@wolff.to>:
> On Thu, Dec 21, 2017 at 23:31:40 +0800,
>  weiping zhang <zwp10758@gmail.com> wrote:
>>
>> does every time boot fail can trigger WANRING in device_add_disk ?
>
>
> Not that I see. But the message could scroll off the screen. The boot gets
> far enough that systemd copies over dmesg output to permanent storage that I
> can see on my next successful boot. That's where I looked for the warning
> output you want. I never saw it for any kernels I compiled myself. Only when
> I test kernels built by Fedora do I see it.
see it every boot ?

> I just tried booting to single user and the boot still hangs.
>
> When I build the kernels, the compiler options are probably a bit different
> than when Fedora does. That might affect what happens during boot.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
