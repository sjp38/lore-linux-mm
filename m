Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3453B6B0038
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 10:38:52 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id h134so13552011iof.11
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 07:38:52 -0800 (PST)
Received: from wolff.to (wolff.to. [98.103.208.27])
        by mx.google.com with SMTP id g194si5272961ita.117.2017.12.21.07.38.51
        for <linux-mm@kvack.org>;
        Thu, 21 Dec 2017 07:38:51 -0800 (PST)
Date: Thu, 21 Dec 2017 09:36:31 -0600
From: Bruno Wolff III <bruno@wolff.to>
Subject: Re: Regression with a0747a859ef6 ("bdi: add error handle for
 bdi_debug_register")
Message-ID: <20171221153631.GA2300@wolff.to>
References: <b1415a6d-fccd-31d0-ffa2-9b54fa699692@redhat.com>
 <20171221130057.GA26743@wolff.to>
 <CAA70yB6Z=r+zO7E+ZP74jXNk_XM2CggYthAD=TKOdBVsHLLV-w@mail.gmail.com>
 <20171221151843.GA453@wolff.to>
 <CAA70yB496Nuy2FM5idxLZthBwOVbhtsZ4VtXNJ_9mj2cvNC4kA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <CAA70yB496Nuy2FM5idxLZthBwOVbhtsZ4VtXNJ_9mj2cvNC4kA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: weiping zhang <zwp10758@gmail.com>
Cc: Laura Abbott <labbott@redhat.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, regressions@leemhuis.info, weiping zhang <zhangweiping@didichuxing.com>, linux-block@vger.kernel.org

On Thu, Dec 21, 2017 at 23:31:40 +0800,
  weiping zhang <zwp10758@gmail.com> wrote:
>does every time boot fail can trigger WANRING in device_add_disk ?

Not that I see. But the message could scroll off the screen. The boot gets 
far enough that systemd copies over dmesg output to permanent storage that 
I can see on my next successful boot. That's where I looked for the warning 
output you want. I never saw it for any kernels I compiled myself. Only 
when I test kernels built by Fedora do I see it.

I just tried booting to single user and the boot still hangs.

When I build the kernels, the compiler options are probably a bit different 
than when Fedora does. That might affect what happens during boot.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
