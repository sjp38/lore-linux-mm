Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id BC9246B0032
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 10:44:13 -0500 (EST)
Received: by mail-la0-f52.google.com with SMTP id hs14so19600894lab.11
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 07:44:12 -0800 (PST)
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com. [209.85.215.44])
        by mx.google.com with ESMTPS id v3si4706579lal.96.2015.01.16.07.44.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 16 Jan 2015 07:44:12 -0800 (PST)
Received: by mail-la0-f44.google.com with SMTP id gd6so19683713lab.3
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 07:44:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150115223157.GB25884@quack.suse.cz>
References: <CANP1eJF77=iH_tm1y0CgF6PwfhUK6WqU9S92d0xAnCt=WhZVfQ@mail.gmail.com>
	<20150115223157.GB25884@quack.suse.cz>
Date: Fri, 16 Jan 2015 10:44:12 -0500
Message-ID: <CANP1eJGRX4w56Ek4j7d2U+F7GNWp6RyOJonxKxTy0phUCpBM9g@mail.gmail.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] async buffered diskio read for userspace apps
From: Milosz Tanski <milosz@adfin.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: lsf-pc@lists.linux-foundation.org, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>

On Thu, Jan 15, 2015 at 5:31 PM, Jan Kara <jack@suse.cz> wrote:
> On Thu 15-01-15 12:43:23, Milosz Tanski wrote:
>> I would like to talk about enhancing the user interfaces for doing
>> async buffered disk IO for userspace applications. There's a whole
>> class of distributed web applications (most new applications today)
>> that would benefit from such an API. Most of them today rely on
>> cobbling one together in user space using a threadpool.
>>
>> The current in kernel AIO interfaces that only support DIRECTIO, they
>> were generally designed by and for big database vendors. The consensus
>> is that the current AIO interfaces usually lead to decreased
>> performance for those app.
>>
>> I've been developing a new read syscall that allows non-blocking
>> diskio read (provided that data is in the page cache). It's analogous
>> to what exists today in the network world with recvmsg with MSG_NOWAIT
>> flag. The work has been previously described by LWN here:
>> https://lwn.net/Articles/612483/
>>
>> Previous attempts (over the last 12+ years) at non-blocking buffered
>> diskio has stalled due to their complexity. I would like to talk about
>> the problem, my solution, and get feedback on the course of action.
>>
>> Over the years I've been building the low level guys of various "web
>> applications". That usually involves async network based applications
>> (epoll based servers) and the biggest pain point for the last 8+ years
>> has been async disk IO.
>   Maybe this topic will be sorted out before LSF/MM. I know Andrew had some
> objections about doc and was suggesting a solution using fincore() (which
> Christoph refuted as being racy). Also there was a pending question
> regarding whether the async read in this form will be used by applications.
> But if it doesn't get sorted out a short session on the pending issues
> would be probably useful.
>
>                                                                 Honza
> --
> Jan Kara <jack@suse.cz>
> SUSE Labs, CR

I've spent the better part of yesterday wrapping up the first cut of
samba support to FIO so we can test a modified samba file server with
these changes in a few scenarios. Right now it's only sync but I hope
to have async in the future. I hope that by the time the summit rolls
around I'll have data to share from samba and maybe some other common
apps (node.js / twisted).

-- 
Milosz Tanski
CTO
16 East 34th Street, 15th floor
New York, NY 10016

p: 646-253-9055
e: milosz@adfin.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
