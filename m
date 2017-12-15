Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 487666B0033
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 12:43:27 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id b11so15755863itj.0
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 09:43:27 -0800 (PST)
Received: from wolff.to (wolff.to. [98.103.208.27])
        by mx.google.com with SMTP id h133si4936905ioa.297.2017.12.15.09.43.26
        for <linux-mm@kvack.org>;
        Fri, 15 Dec 2017 09:43:26 -0800 (PST)
Date: Fri, 15 Dec 2017 11:40:13 -0600
From: Bruno Wolff III <bruno@wolff.to>
Subject: Re: Regression with a0747a859ef6 ("bdi: add error handle for
 bdi_debug_register")
Message-ID: <20171215174013.GA20381@wolff.to>
References: <20171214082452.GA16698@wolff.to>
 <20171214100927.GA26167@localhost.didichuxing.com>
 <20171214154136.GA12936@wolff.to>
 <CAA70yB6yofLz8pfhxXfq29sYqcGmBYLOvSruXi9XS_HM6mUrxg@mail.gmail.com>
 <20171215014417.GA17757@wolff.to>
 <CAA70yB6spi5c38kFVidRsJVaYc3W9tvpZz6wy+28rK7oeefQfw@mail.gmail.com>
 <20171215111050.GA30737@wolff.to>
 <CAA70yB66ekUGAvusQbqo7BLV+uBJtNz72cr+tZitsfjuVRWuXA@mail.gmail.com>
 <20171215163048.GA15928@wolff.to>
 <533198ad-b756-3e0a-c3bd-9aae0a42d170@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <533198ad-b756-3e0a-c3bd-9aae0a42d170@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: weiping zhang <zwp10758@gmail.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, regressions@leemhuis.info, linux-block@vger.kernel.org

On Fri, Dec 15, 2017 at 09:18:56 -0800,
  Laura Abbott <labbott@redhat.com> wrote:
>
>You can see the trees Fedora produces at https://git.kernel.org/pub/scm/linux/kernel/git/jwboyer/fedora.git
>which includes the configs (you want to look at the ones withtout - debug)

Thanks. I found it a little while ago and am already doing a test build 
without weiping's test patch to see if that kernel provides what he(?) 
needs. Doing a rebuild with the test patch will go pretty quickly. So 
if I get the message with device_add_disk from these kernels, I should 
be able to get the information this afternoon. If there is some other 
reason I don't get that when I do the builds, I'm probably not going to be 
able to figure it out and get a build done before I leave. I don't live 
close enough to the office that I'm going to want to drive in just to 
be able to do a reboot test. (And my hardware at home does exhibit the 
problem.)

If you have some other idea about why I might not be seeing the 
device_add_disk message, I'd be interested in hearing it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
