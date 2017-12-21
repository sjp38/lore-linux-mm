Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 751AD6B0260
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 10:31:42 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id k126so4190617wmd.5
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 07:31:42 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q6sor10913755edb.27.2017.12.21.07.31.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Dec 2017 07:31:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171221151843.GA453@wolff.to>
References: <b1415a6d-fccd-31d0-ffa2-9b54fa699692@redhat.com>
 <20171221130057.GA26743@wolff.to> <CAA70yB6Z=r+zO7E+ZP74jXNk_XM2CggYthAD=TKOdBVsHLLV-w@mail.gmail.com>
 <20171221151843.GA453@wolff.to>
From: weiping zhang <zwp10758@gmail.com>
Date: Thu, 21 Dec 2017 23:31:40 +0800
Message-ID: <CAA70yB496Nuy2FM5idxLZthBwOVbhtsZ4VtXNJ_9mj2cvNC4kA@mail.gmail.com>
Subject: Re: Regression with a0747a859ef6 ("bdi: add error handle for bdi_debug_register")
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bruno Wolff III <bruno@wolff.to>
Cc: Laura Abbott <labbott@redhat.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, regressions@leemhuis.info, weiping zhang <zhangweiping@didichuxing.com>, linux-block@vger.kernel.org

2017-12-21 23:18 GMT+08:00 Bruno Wolff III <bruno@wolff.to>:
> On Thu, Dec 21, 2017 at 22:01:33 +0800,
>  weiping zhang <zwp10758@gmail.com> wrote:
>>
>> Hi,
>> how do you do bisect ?build all kernel commit one by one ?
>> as you did before:
>> https://bugzilla.redhat.com/show_bug.cgi?id=1520982
>
>
> I just did the one bisect using Linus' tree. After each build, I would do a
> test boot and see if the boot was normal or if I got errors and an eventual
> hang before boot.
>
> Since then I have used git revert to revert just the problem commit from
> later kernels (such as v4.15-rc4) and when I do the system boots normally.
> And when I don't do the revert or just use stock Fedora kernels the problem
> occurs every time.
does every time boot fail can trigger WANRING in device_add_disk ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
