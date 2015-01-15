Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id 07BB46B0032
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 13:30:36 -0500 (EST)
Received: by mail-qc0-f175.google.com with SMTP id p6so13549696qcv.6
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 10:30:35 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p19si2990434qgd.27.2015.01.15.10.30.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jan 2015 10:30:35 -0800 (PST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [LSF/MM TOPIC] async buffered diskio read for userspace apps
References: <CANP1eJF77=iH_tm1y0CgF6PwfhUK6WqU9S92d0xAnCt=WhZVfQ@mail.gmail.com>
Date: Thu, 15 Jan 2015 13:30:05 -0500
In-Reply-To: <CANP1eJF77=iH_tm1y0CgF6PwfhUK6WqU9S92d0xAnCt=WhZVfQ@mail.gmail.com>
	(Milosz Tanski's message of "Thu, 15 Jan 2015 12:43:23 -0500")
Message-ID: <x49zj9jaocy.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Milosz Tanski <milosz@adfin.com>
Cc: lsf-pc@lists.linux-foundation.org, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>

Milosz Tanski <milosz@adfin.com> writes:

> I would like to talk about enhancing the user interfaces for doing
> async buffered disk IO for userspace applications. There's a whole
> class of distributed web applications (most new applications today)
> that would benefit from such an API. Most of them today rely on
> cobbling one together in user space using a threadpool.
>
> The current in kernel AIO interfaces that only support DIRECTIO, they
> were generally designed by and for big database vendors. The consensus
> is that the current AIO interfaces usually lead to decreased
> performance for those app.
>
> I've been developing a new read syscall that allows non-blocking
> diskio read (provided that data is in the page cache). It's analogous
> to what exists today in the network world with recvmsg with MSG_NOWAIT
> flag. The work has been previously described by LWN here:
> https://lwn.net/Articles/612483/
>
> Previous attempts (over the last 12+ years) at non-blocking buffered
> diskio has stalled due to their complexity. I would like to talk about
> the problem, my solution, and get feedback on the course of action.

This email seems to conflate async I/O and non-blocking I/O.  Could you
please be more specific about what you're proposing to talk about?  Is
it just the non-blocking read support?

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
