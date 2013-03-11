Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id B3AAC6B0005
	for <linux-mm@kvack.org>; Mon, 11 Mar 2013 09:16:04 -0400 (EDT)
Received: by mail-we0-f173.google.com with SMTP id x51so3448349wey.18
        for <linux-mm@kvack.org>; Mon, 11 Mar 2013 06:16:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAOMqctTf9+sz7Ffm-mLLeGNqH27yvuM+vORrG65Yoh3JKDFLnQ@mail.gmail.com>
References: <CAOMqctTf9+sz7Ffm-mLLeGNqH27yvuM+vORrG65Yoh3JKDFLnQ@mail.gmail.com>
From: Michal Suchanek <hramrach@gmail.com>
Date: Mon, 11 Mar 2013 14:15:43 +0100
Message-ID: <CAOMqctRiLa-uVaD=omeOT5o-UdcOJo6WgOm8nBaN6S-x+Dh1KA@mail.gmail.com>
Subject: Re: doing lots of disk writes causes oom killer to kill processes
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, 699277@bugs.debian.org

On 8 February 2013 17:31, Michal Suchanek <hramrach@gmail.com> wrote:
> Hello,
>
> I am dealing with VM disk images and performing something like wiping
> free space to prepare image for compressing and storing on server or
> copying it to external USB disk causes
>
> 1) system lockup in order of a few tens of seconds when all CPU cores
> are 100% used by system and the machine is basicaly unusable
>
> 2) oom killer killing processes
>
> This all on system with 8G ram so there should be plenty space to work with.
>
> This happens with kernels 3.6.4 or 3.7.1
>
> With earlier kernel versions (some 3.0 or 3.2 kernels) this was not a
> problem even with less ram.
>
> I have  vm.swappiness = 0 set for a long  time already.
>
>
I did some testing with 3.7.1 and with swappiness as much as 75 the
kernel still causes all cores to loop somewhere in system when writing
lots of data to disk.

With swappiness as much as 90 processes still get killed on large disk writes.

Given that the max is 100 the interval in which mm works at all is
going to be very narrow, less than 10% of the paramater range. This is
a severe regression as is the cpu time consumed by the kernel.

The io scheduler is the default cfq.

If you have any idea what to try other than downgrading to an earlier
unaffected kernel I would like to hear.

Thanks

Michal

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
