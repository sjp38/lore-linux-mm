Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8FE976B0033
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 12:02:19 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id t18so11365648oie.5
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 09:02:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u1sor4099802iti.101.2017.12.21.09.02.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Dec 2017 09:02:17 -0800 (PST)
Subject: Re: Regression with a0747a859ef6 ("bdi: add error handle for
 bdi_debug_register")
References: <b1415a6d-fccd-31d0-ffa2-9b54fa699692@redhat.com>
 <20171221130057.GA26743@wolff.to>
 <CAA70yB6Z=r+zO7E+ZP74jXNk_XM2CggYthAD=TKOdBVsHLLV-w@mail.gmail.com>
 <20171221151843.GA453@wolff.to>
 <CAA70yB496Nuy2FM5idxLZthBwOVbhtsZ4VtXNJ_9mj2cvNC4kA@mail.gmail.com>
 <20171221153631.GA2300@wolff.to>
 <CAA70yB6nD7CiDZUpVPy7cGhi7ooQ5SPkrcXPDKqSYD2ezLrGHA@mail.gmail.com>
 <20171221164221.GA23680@wolff.to>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <14f04d43-728a-953f-e07c-e7f9d5e3392d@kernel.dk>
Date: Thu, 21 Dec 2017 10:02:15 -0700
MIME-Version: 1.0
In-Reply-To: <20171221164221.GA23680@wolff.to>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bruno Wolff III <bruno@wolff.to>, weiping zhang <zwp10758@gmail.com>
Cc: Laura Abbott <labbott@redhat.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, regressions@leemhuis.info, weiping zhang <zhangweiping@didichuxing.com>, linux-block@vger.kernel.org

On 12/21/17 9:42 AM, Bruno Wolff III wrote:
> On Thu, Dec 21, 2017 at 23:48:19 +0800,
>   weiping zhang <zwp10758@gmail.com> wrote:
>>> output you want. I never saw it for any kernels I compiled myself. Only when
>>> I test kernels built by Fedora do I see it.
>> see it every boot ?
> 
> I don't look every boot. The warning gets scrolled of the screen. Once I see 
> the CPU hang warnings I know the boot is failing. I don't always look 
> at journalctl later to see what's there.

I'm going to revert a0747a859ef6 for now, since we're now 8 days into this
and no progress has been made on fixing it.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
