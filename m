Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0D1CA6B0033
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 12:19:01 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id p4so5039334oti.15
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 09:19:01 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e138sor594985oih.175.2017.12.15.09.18.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Dec 2017 09:19:00 -0800 (PST)
Subject: Re: Regression with a0747a859ef6 ("bdi: add error handle for
 bdi_debug_register")
References: <b1415a6d-fccd-31d0-ffa2-9b54fa699692@redhat.com>
 <20171214082452.GA16698@wolff.to>
 <20171214100927.GA26167@localhost.didichuxing.com>
 <20171214154136.GA12936@wolff.to>
 <CAA70yB6yofLz8pfhxXfq29sYqcGmBYLOvSruXi9XS_HM6mUrxg@mail.gmail.com>
 <20171215014417.GA17757@wolff.to>
 <CAA70yB6spi5c38kFVidRsJVaYc3W9tvpZz6wy+28rK7oeefQfw@mail.gmail.com>
 <20171215111050.GA30737@wolff.to>
 <CAA70yB66ekUGAvusQbqo7BLV+uBJtNz72cr+tZitsfjuVRWuXA@mail.gmail.com>
 <20171215163048.GA15928@wolff.to>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <533198ad-b756-3e0a-c3bd-9aae0a42d170@redhat.com>
Date: Fri, 15 Dec 2017 09:18:56 -0800
MIME-Version: 1.0
In-Reply-To: <20171215163048.GA15928@wolff.to>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bruno Wolff III <bruno@wolff.to>, weiping zhang <zwp10758@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, regressions@leemhuis.info, linux-block@vger.kernel.org

On 12/15/2017 08:30 AM, Bruno Wolff III wrote:
> On Fri, Dec 15, 2017 at 22:02:20 +0800,
>  A weiping zhang <zwp10758@gmail.com> wrote:
>>
>> Yes, please help reproduce this issue include my debug patch. Reproduce means
>> we can see WARN_ON in device_add_disk caused by failure of bdi_register_owner.
> 
> I'm not sure why yet, but I'm only getting the warning message you want with Fedora kernels, not the ones I am building (with or without your test patch). I'll attach a debug config file if you want to look there. But in theory that should be essentially what Fedora is using for theirs. They probably have some out of tree patches they are applying, but I wouldn't expect those to make a difference here. I think they now have a tree somewhere that I can try to build from that has their patches applied to the upstream kernel and if I can find it I will try building it just to test this out.
> 
> I only have about 6 hours of physical access to the machine exhibiting the problem, and after that I won't be able to do test boots until Monday.


You can see the trees Fedora produces at https://git.kernel.org/pub/scm/linux/kernel/git/jwboyer/fedora.git
which includes the configs (you want to look at the ones withtout - debug)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
