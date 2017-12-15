Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7DB636B0038
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 20:47:24 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id p144so11683988itc.9
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 17:47:24 -0800 (PST)
Received: from wolff.to (wolff.to. [98.103.208.27])
        by mx.google.com with SMTP id f141si4195428itf.12.2017.12.14.17.47.23
        for <linux-mm@kvack.org>;
        Thu, 14 Dec 2017 17:47:23 -0800 (PST)
Date: Thu, 14 Dec 2017 19:44:17 -0600
From: Bruno Wolff III <bruno@wolff.to>
Subject: Re: Regression with a0747a859ef6 ("bdi: add error handle for
 bdi_debug_register")
Message-ID: <20171215014417.GA17757@wolff.to>
References: <b1415a6d-fccd-31d0-ffa2-9b54fa699692@redhat.com>
 <20171214082452.GA16698@wolff.to>
 <20171214100927.GA26167@localhost.didichuxing.com>
 <20171214154136.GA12936@wolff.to>
 <CAA70yB6yofLz8pfhxXfq29sYqcGmBYLOvSruXi9XS_HM6mUrxg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <CAA70yB6yofLz8pfhxXfq29sYqcGmBYLOvSruXi9XS_HM6mUrxg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: weiping zhang <zwp10758@gmail.com>
Cc: Laura Abbott <labbott@redhat.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, regressions@leemhuis.info, linux-block@vger.kernel.org

On Fri, Dec 15, 2017 at 09:22:21 +0800,
  weiping zhang <zwp10758@gmail.com> wrote:
>
>Thanks your testing, but I cann't find WARN_ON in device_add_disk from
>this boot1.log, could you help reproduce that issue? And does this issue can be
>triggered at every bootup ?

I don't know what you need for the first question. When I am physically at 
the machine I can do test reboots. If you have something specific you want 
me to try I should be able to.

Every time I boot with the problem commit, the boot never completes. However 
it does seem to get pretty far. I get multiple register dumps every time. 
After a while (a few minutes) I reboot to a wrking kernel.

The output I included is from: journalctl -k -b -1
If you think it would be better to see more than dmesg output let me know.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
