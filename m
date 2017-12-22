Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id C98AB6B0038
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 09:06:46 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id q15so1028581ioi.4
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 06:06:46 -0800 (PST)
Received: from wolff.to (wolff.to. [98.103.208.27])
        by mx.google.com with SMTP id w12si16255470iow.35.2017.12.22.06.06.45
        for <linux-mm@kvack.org>;
        Fri, 22 Dec 2017 06:06:45 -0800 (PST)
Date: Fri, 22 Dec 2017 08:04:23 -0600
From: Bruno Wolff III <bruno@wolff.to>
Subject: Re: Regression with a0747a859ef6 ("bdi: add error handle for
 bdi_debug_register")
Message-ID: <20171222140423.GA23107@wolff.to>
References: <20171221151843.GA453@wolff.to>
 <CAA70yB496Nuy2FM5idxLZthBwOVbhtsZ4VtXNJ_9mj2cvNC4kA@mail.gmail.com>
 <20171221153631.GA2300@wolff.to>
 <CAA70yB6nD7CiDZUpVPy7cGhi7ooQ5SPkrcXPDKqSYD2ezLrGHA@mail.gmail.com>
 <20171221164221.GA23680@wolff.to>
 <14f04d43-728a-953f-e07c-e7f9d5e3392d@kernel.dk>
 <20171221181531.GA21050@wolff.to>
 <20171221231603.GA15702@wolff.to>
 <20171222045318.GA4505@wolff.to>
 <CAA70yB5y1uLvtvEFLsE2C_ALLvSqEZ6XKA=zoPeSaH_eSAVL4w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <CAA70yB5y1uLvtvEFLsE2C_ALLvSqEZ6XKA=zoPeSaH_eSAVL4w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: weiping zhang <zwp10758@gmail.com>
Cc: Jens Axboe <axboe@kernel.dk>, Laura Abbott <labbott@redhat.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, regressions@leemhuis.info, weiping zhang <zhangweiping@didichuxing.com>, linux-block@vger.kernel.org

On Fri, Dec 22, 2017 at 21:20:10 +0800,
  weiping zhang <zwp10758@gmail.com> wrote:
>2017-12-22 12:53 GMT+08:00 Bruno Wolff III <bruno@wolff.to>:
>> On Thu, Dec 21, 2017 at 17:16:03 -0600,
>>  Bruno Wolff III <bruno@wolff.to> wrote:
>>>
>>>
>>> Enforcing mode alone isn't enough as I tested that one one machine at home
>>> and it didn't trigger the problem. I'll try another machine late tonight.
>>
>>
>> I got the problem to occur on my i686 machine when booting in enforcing
>> mode. This machine uses raid 1 vua mdraid which may or may not be a factor
>> in this problem. The boot log has a trace at the end and might be helpful,
>> so I'm attaching it here.
>Hi Bruno,
>I can reproduce this issue in my QEMU test VM easily, just add an soft
>RAID1, always trigger
>that warning, I'll debug it later.

Great. When you have a fix, I can test it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
