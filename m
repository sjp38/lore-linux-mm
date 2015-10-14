Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9C8076B0255
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 15:01:12 -0400 (EDT)
Received: by igbhv6 with SMTP id hv6so24411989igb.0
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 12:01:12 -0700 (PDT)
Received: from mail-ig0-x235.google.com (mail-ig0-x235.google.com. [2607:f8b0:4001:c05::235])
        by mx.google.com with ESMTPS id sd6si18259152igb.63.2015.10.14.12.01.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Oct 2015 12:01:11 -0700 (PDT)
Received: by igbkq10 with SMTP id kq10so119352194igb.0
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 12:01:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFz+_Zh7O544QL3YCjTr1rfb-Q82wAyHTK8QMr+9X81h2g@mail.gmail.com>
References: <20151013214952.GB23106@mtj.duckdns.org>
	<CA+55aFzV61qsWOObLUPpL-2iU1=8EopEgfse+kRGuUi9kevoOA@mail.gmail.com>
	<20151014165729.GA12799@mtj.duckdns.org>
	<CA+55aFzhHF0KMFvebegBnwHqXekfRRd-qczCtJXKpf3XvOCW=A@mail.gmail.com>
	<alpine.DEB.2.20.1510141253570.13238@east.gentwo.org>
	<CA+55aFz+_Zh7O544QL3YCjTr1rfb-Q82wAyHTK8QMr+9X81h2g@mail.gmail.com>
Date: Wed, 14 Oct 2015 12:01:11 -0700
Message-ID: <CA+55aFwed4Q=T48QxNqhL3UL_f1XqQEBJ6mnA42iWiOAiZZO9A@mail.gmail.com>
Subject: Re: [GIT PULL] workqueue fixes for v4.3-rc5
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Shaohua Li <shli@fb.com>, linux-mm <linux-mm@kvack.org>

On Wed, Oct 14, 2015 at 11:37 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Yes, yes, it so _happens_ that "add_timer()" preferentially uses the
> current CPU etc, so in practice it may have happened to work. But
> there's absolutely zero reason to think it should always work that
> way.

Side note: even in practice, I think things like off-lining CPU's etc
(which some mobile environments seem to do as a power saving thing)
can end up moving timers to other CPU's even if they originally got
added on a particular cpu.

So I really think that the whole "schedule_delayed_work() ends up
running on the CPU" has actually never "really" been true. It has at
most been a "most of the time" thing, making it hard to see the
problem in practice.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
