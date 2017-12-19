Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 09FA46B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 14:52:32 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id y200so2924792itc.7
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 11:52:32 -0800 (PST)
Received: from wolff.to (wolff.to. [98.103.208.27])
        by mx.google.com with SMTP id f76si1721712itf.87.2017.12.19.11.52.30
        for <linux-mm@kvack.org>;
        Tue, 19 Dec 2017 11:52:30 -0800 (PST)
Date: Tue, 19 Dec 2017 13:48:35 -0600
From: Bruno Wolff III <bruno@wolff.to>
Subject: Re: Regression with a0747a859ef6 ("bdi: add error handle for
 bdi_debug_register")
Message-ID: <20171219194835.GA5571@wolff.to>
References: <CAA70yB6yofLz8pfhxXfq29sYqcGmBYLOvSruXi9XS_HM6mUrxg@mail.gmail.com>
 <20171215014417.GA17757@wolff.to>
 <CAA70yB6spi5c38kFVidRsJVaYc3W9tvpZz6wy+28rK7oeefQfw@mail.gmail.com>
 <20171215111050.GA30737@wolff.to>
 <CAA70yB66ekUGAvusQbqo7BLV+uBJtNz72cr+tZitsfjuVRWuXA@mail.gmail.com>
 <20171215195122.GA27126@wolff.to>
 <20171216163226.GA1796@wolff.to>
 <CAA70yB7wL_Wq5S8XQ9zHuLPDdwepv7dYdKALL8Sg0q6CNdAz5g@mail.gmail.com>
 <20171219161743.GA6960@wolff.to>
 <20171219182452.vpmqpi3yb4g2ecad@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20171219182452.vpmqpi3yb4g2ecad@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: weiping zhang <zwp10758@gmail.com>, Laura Abbott <labbott@redhat.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, regressions@leemhuis.info, linux-block@vger.kernel.org

On Tue, Dec 19, 2017 at 10:24:52 -0800,
  Shaohua Li <shli@kernel.org> wrote:
>
>Not sure if this is MD related, but could you please check if this debug patch
>changes anything?

I'm doing a build now. I do use md to mirror disk partitions between two disks. I do that on another machine that doesn't exhibit the problem, but it is 
i686, not x86_64.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
