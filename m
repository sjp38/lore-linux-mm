Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id BB0AE6B028B
	for <linux-mm@kvack.org>; Fri, 28 Oct 2016 21:26:59 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id e200so155285659oig.4
        for <linux-mm@kvack.org>; Fri, 28 Oct 2016 18:26:59 -0700 (PDT)
Received: from mail-oi0-x241.google.com (mail-oi0-x241.google.com. [2607:f8b0:4003:c06::241])
        by mx.google.com with ESMTPS id e1si11337470oic.88.2016.10.28.18.26.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Oct 2016 18:26:58 -0700 (PDT)
Received: by mail-oi0-x241.google.com with SMTP id 62so2333707oif.1
        for <linux-mm@kvack.org>; Fri, 28 Oct 2016 18:26:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CADzA9onmVegryn6aQW22+FzMqpuCBfEAG5zDN5vUbb3UgBs5_w@mail.gmail.com>
References: <bug-180101-27@https.bugzilla.kernel.org/> <20161028145215.87fd39d8f8822a2cd11b621c@linux-foundation.org>
 <CADzA9onJOyKGWkzzr7HP742-xXpiJciNddhv946Yg_tPSszTDQ@mail.gmail.com>
 <CA+55aFyJmxLvFfM=KnoBqm01YYvBs136p7gJSmatJzj0cXarRQ@mail.gmail.com> <CADzA9onmVegryn6aQW22+FzMqpuCBfEAG5zDN5vUbb3UgBs5_w@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 28 Oct 2016 18:26:57 -0700
Message-ID: <CA+55aFxvDcZ-eX-=vE48y82xyextYs-UPj9Wm-kVZ8nfoL5GEQ@mail.gmail.com>
Subject: Re: [Bug 180101] New: BUG: unable to handle kernel paging request at
 x with "mm: remove gup_flags FOLL_WRITE games from __get_user_pages()"
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joseph Yasi <joe.yasi@gmail.com>
Cc: bugzilla-daemon@bugzilla.kernel.org, Chris Mason <clm@fb.com>, Kent Overstreet <kent.overstreet@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>

On Fri, Oct 28, 2016 at 6:00 PM, Joseph Yasi <joe.yasi@gmail.com> wrote:
>>
>> But also, please test if this happens without the out-of-tree modules?
>
> I was testing it without VirtualBox and broadcom-wl out-of-tree modules, and
> the machine locked up and won't POST anymore. The motherboard is claiming
> it's the CPU, so it looks like this was hardware. Sorry for the noise.

Hey, sorry about your hardware, but happy it isn't our software ;)

        Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
