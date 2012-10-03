Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id C87CD6B005A
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 09:30:18 -0400 (EDT)
Received: by padfa10 with SMTP id fa10so7422779pad.14
        for <linux-mm@kvack.org>; Wed, 03 Oct 2012 06:30:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAA25o9TmsnR3T+CLk5LeRmXv3s8b719KrSU6C919cAu0YMKPkA@mail.gmail.com>
References: <CAA25o9TmsnR3T+CLk5LeRmXv3s8b719KrSU6C919cAu0YMKPkA@mail.gmail.com>
Date: Wed, 3 Oct 2012 09:30:17 -0400
Message-ID: <CACJDEmphUupZK7y5EMqpsi91hzSexUCvxh8k2LwG0pLeCzCVKg@mail.gmail.com>
Subject: Re: zram OOM behavior
From: Konrad Rzeszutek Wilk <konrad@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: linux-mm@kvack.org

On Fri, Sep 28, 2012 at 1:32 PM, Luigi Semenzato <semenzato@google.com> wrote:
> Greetings,
>
> We are experimenting with zram in Chrome OS.  It works quite well
> until the system runs out of memory, at which point it seems to hang,
> but we suspect it is thrashing.

Or spinning in some sad loop. Does the kernel have the CONFIG_DETECT_*
options to figure out what is happening? Can you invoke the Alt-SysRQ
when it is hung?
>
> Before the (apparent) hang, the OOM killer gets rid of a few
> processes, but then the other processes gradually stop responding,
> until the entire system becomes unresponsive.

Does the OOM give you an idea what the memory state is? Can you
actually provide the dmesg?

>
> I am wondering if anybody has run into this.  Thanks!
>
> Luigi
>
> P.S.  For those who wish to know more:
>
> 1. We use the min_filelist_kbytes patch
> (http://lwn.net/Articles/412313/)  (I am not sure if it made it into
> the standard kernel) and set min_filelist_kbytes to 50Mb.  (This may
> not matter, as it's unlikely to make things worse.)
>
> 2. We swap only to compressed ram.  The setup is very simple:
>
>  echo ${ZRAM_SIZE_KB}000 >/sys/block/zram0/disksize ||
>       logger -t "$UPSTART_JOB" "failed to set zram size"
>   mkswap /dev/zram0 || logger -t "$UPSTART_JOB" "mkswap /dev/zram0 failed"
>   swapon /dev/zram0 || logger -t "$UPSTART_JOB" "swapon /dev/zram0 failed"
>
> For ZRAM_SIZE_KB, we typically use 1.5 the size of RAM (which is 2 or
> 4 Gb).  The compression factor is about 3:1.  The hangs happen for
> quite a wide range of zram sizes.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
