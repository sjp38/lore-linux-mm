Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4F6D06B0069
	for <linux-mm@kvack.org>; Sun, 17 Dec 2017 10:58:22 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id x32so2662709ita.1
        for <linux-mm@kvack.org>; Sun, 17 Dec 2017 07:58:22 -0800 (PST)
Received: from wolff.to (wolff.to. [98.103.208.27])
        by mx.google.com with SMTP id d189si8008548itg.40.2017.12.17.07.58.21
        for <linux-mm@kvack.org>;
        Sun, 17 Dec 2017 07:58:21 -0800 (PST)
Date: Sun, 17 Dec 2017 09:54:48 -0600
From: Bruno Wolff III <bruno@wolff.to>
Subject: Re: Regression with a0747a859ef6 ("bdi: add error handle for
 bdi_debug_register")
Message-ID: <20171217155448.GA20370@wolff.to>
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

No, the first log (that Laura copied) was from the Fedora bug and it was 
from a Fedora kernel before I started doing the bisect. That warnings are 
missing from all of my builds, not just the ones from the patches.

I didn't spot anything obvious going through the kernel spec file when 
I looked, but I could easily have missed something.

Hopefully it is just a boot default that is different and that I can 
override it with a kernel boot parameter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
