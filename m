From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/8][for -mm] mem_notify v6
Date: Wed, 02 Apr 2008 16:31:27 +0900
Message-ID: <20080402154910.9588.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <2f11576a0802090719i3c08a41aj38504e854edbfeac@mail.gmail.com> <ab3f9b940804011635g2de833d0l44558f78a1cce1e5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754138AbYDBHbW@vger.kernel.org>
In-Reply-To: <ab3f9b940804011635g2de833d0l44558f78a1cce1e5@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Tom May <tom@tommay.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

Hi Tom,

Thank you very useful comment.
that is very interesting.

> I tried it with a real-world program that, among other things, mmaps
> anonymous pages and touches them at a reasonable speed until it gets
> notified via /dev/mem_notify, releases most of them with
> madvise(MADV_DONTNEED), then loops to start the cycle again.
>
> What tends to happen is that I do indeed get notifications via
> /dev/mem_notify when the kernel would like to be swapping, at which
> point I free memory.  But the notifications come at a time when the
> kernel needs memory, and it gets the memory by discarding some Cached
> or Mapped memory (I can see these decreasing in /proc/meminfo with
> each notification).  With each mmap/notify/madvise cycle the Cached
> and Mapped memory gets smaller, until eventually while I'm touching
> pages the kernel can't find enough memory and will either invoke the
> OOM killer or return ENOMEM from syscalls.  This is precisely the
> situation I'm trying to avoid by using /dev/mem_notify.

Could you send your test program?
I can't reproduce that now, sorry.


> The criterion of "notify when the kernel would like to swap" feels
> correct, but in addition I seem to need something like "notify when
> cached+mapped+free memory is getting low".

Hmmm,
I think this idea is only useful when userland process call 
madvise(MADV_DONTNEED) periodically.

but I hope improve my patch and solve your problem.
if you don' mind, please help my testing ;)
