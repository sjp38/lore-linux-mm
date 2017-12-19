Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 13B686B026C
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 11:21:38 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id b11so2462683itj.0
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 08:21:38 -0800 (PST)
Received: from wolff.to (wolff.to. [98.103.208.27])
        by mx.google.com with SMTP id v81si4571674ioi.128.2017.12.19.08.21.36
        for <linux-mm@kvack.org>;
        Tue, 19 Dec 2017 08:21:37 -0800 (PST)
Date: Tue, 19 Dec 2017 10:17:43 -0600
From: Bruno Wolff III <bruno@wolff.to>
Subject: Re: Regression with a0747a859ef6 ("bdi: add error handle for
 bdi_debug_register")
Message-ID: <20171219161743.GA6960@wolff.to>
References: <20171214100927.GA26167@localhost.didichuxing.com>
 <20171214154136.GA12936@wolff.to>
 <CAA70yB6yofLz8pfhxXfq29sYqcGmBYLOvSruXi9XS_HM6mUrxg@mail.gmail.com>
 <20171215014417.GA17757@wolff.to>
 <CAA70yB6spi5c38kFVidRsJVaYc3W9tvpZz6wy+28rK7oeefQfw@mail.gmail.com>
 <20171215111050.GA30737@wolff.to>
 <CAA70yB66ekUGAvusQbqo7BLV+uBJtNz72cr+tZitsfjuVRWuXA@mail.gmail.com>
 <20171215195122.GA27126@wolff.to>
 <20171216163226.GA1796@wolff.to>
 <CAA70yB7wL_Wq5S8XQ9zHuLPDdwepv7dYdKALL8Sg0q6CNdAz5g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <CAA70yB7wL_Wq5S8XQ9zHuLPDdwepv7dYdKALL8Sg0q6CNdAz5g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: weiping zhang <zwp10758@gmail.com>
Cc: Laura Abbott <labbott@redhat.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, regressions@leemhuis.info, linux-block@vger.kernel.org

On Sun, Dec 17, 2017 at 21:43:50 +0800,
  weiping zhang <zwp10758@gmail.com> wrote:
>Hi, thanks for testing, I think you first reproduce this issue(got WARNING
>at device_add_disk) by your own build, then add my debug patch.

The problem is still in rc4. Reverting the commit still fixes the problem. 
I tested that warning level messages should appear using lkdtm. While 
there could be something weird relating to the WARN_ON macro, more likely 
there is something different about the boots with the kernels I build 
(the exact way initramfs is built is probably different) and probably 
that (WARN_ON) code is not getting executed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
