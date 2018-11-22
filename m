Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id EEE0A6B2957
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 23:01:32 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id f24so7296322ioh.21
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 20:01:32 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t16-v6sor5037248ita.13.2018.11.21.20.01.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Nov 2018 20:01:31 -0800 (PST)
MIME-Version: 1.0
References: <20181120221659.GA61322@dennisz-mbp.dhcp.thefacebook.com>
In-Reply-To: <20181120221659.GA61322@dennisz-mbp.dhcp.thefacebook.com>
From: Vlad Dumitrescu <vladum@google.com>
Date: Wed, 21 Nov 2018 20:01:04 -0800
Message-ID: <CABDEL=+Q7eOycRC9zvjdffq3Kyn6Fcau4HVponM-Y6-dHYewNg@mail.gmail.com>
Subject: Re: LPC Traffic Shaping w/ BPF Talk - percpu followup
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dennis@kernel.org
Cc: Eddie Hao <eddieh@google.com>, Willem de Bruijn <willemb@google.com>, ast@kernel.org, tj@kernel.org, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Eric Dumazet <edumazet@google.com>

On Tue, Nov 20, 2018 at 2:17 PM Dennis Zhou <dennis@kernel.org> wrote:
>
> Hi Eddie, Vlad, and Willem,
>
> A few people mentioned to me that you guys were experiencing issues with
> the percpu memory allocator. I saw the talk slides mention the
> following two bullets:
>
> 1) allocation pattern makes the per cpu allocator reach a highly
>    fragmented state
> 2) sometimes takes a long time (up to 12s) to create the PERCPU_HASH
>    maps at startup
>
> Could you guys elaborate a little more about the above? Some things
> that would help: kernel version, cpu info, and a reproducer if possible?
>
> Also, I did some work last summer to make percpu allocation more
> efficient, which went into the 4.14 kernel. Just to be sure, is that a
> part of the kernel you guys are running?
>
> Thanks,
> Dennis

Hi, Dennis,

Thanks a lot for reaching out and sorry for the delay in answering. I
was trying to build something which shows the problem on a recent
upstream kernel, but I was unable to do so until now.

It seems like I can still reliably reproduce on one of our kernels,
which has a lot of 'percpu: *' patches by you from 4.14, and with an
internal application. Unfortunately, we haven't spent too much time on
this issue, and I will have 'page in' state from a few months back.
Hopefully, I'll be able to reproduce on a vanilla kernel and a simpler
application, that we can publish, in the following days (after TG
weekend).

Thanks,
Vlad
