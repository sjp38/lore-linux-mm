Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id DE0C16B0033
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 18:18:27 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id q25so2563111ioh.4
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 15:18:27 -0800 (PST)
Received: from wolff.to (wolff.to. [98.103.208.27])
        by mx.google.com with SMTP id d4si10900910ioc.34.2017.12.21.15.18.26
        for <linux-mm@kvack.org>;
        Thu, 21 Dec 2017 15:18:26 -0800 (PST)
Date: Thu, 21 Dec 2017 17:16:03 -0600
From: Bruno Wolff III <bruno@wolff.to>
Subject: Re: Regression with a0747a859ef6 ("bdi: add error handle for
 bdi_debug_register")
Message-ID: <20171221231603.GA15702@wolff.to>
References: <b1415a6d-fccd-31d0-ffa2-9b54fa699692@redhat.com>
 <20171221130057.GA26743@wolff.to>
 <CAA70yB6Z=r+zO7E+ZP74jXNk_XM2CggYthAD=TKOdBVsHLLV-w@mail.gmail.com>
 <20171221151843.GA453@wolff.to>
 <CAA70yB496Nuy2FM5idxLZthBwOVbhtsZ4VtXNJ_9mj2cvNC4kA@mail.gmail.com>
 <20171221153631.GA2300@wolff.to>
 <CAA70yB6nD7CiDZUpVPy7cGhi7ooQ5SPkrcXPDKqSYD2ezLrGHA@mail.gmail.com>
 <20171221164221.GA23680@wolff.to>
 <14f04d43-728a-953f-e07c-e7f9d5e3392d@kernel.dk>
 <20171221181531.GA21050@wolff.to>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20171221181531.GA21050@wolff.to>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: weiping zhang <zwp10758@gmail.com>, Laura Abbott <labbott@redhat.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, regressions@leemhuis.info, weiping zhang <zhangweiping@didichuxing.com>, linux-block@vger.kernel.org

On Thu, Dec 21, 2017 at 12:15:31 -0600,
  Bruno Wolff III <bruno@wolff.to> wrote:
>
>One important thing I have just found is that it looks like the 
>problem only happens when booting in enforcing mode. If I boot in 
>permissive mode it does not happen. My home machines are currently set 
>to boot in permissive mode and I'll test this evening to see if I can 
>reproduce the problem if I change them to enforcing mode. If so I'll 
>be able to do lots of testing during my vacation.

Enforcing mode alone isn't enough as I tested that one one machine at 
home and it didn't trigger the problem. I'll try another machine late 
tonight.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
