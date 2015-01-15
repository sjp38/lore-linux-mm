Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id C9A786B006C
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 12:43:24 -0500 (EST)
Received: by mail-la0-f44.google.com with SMTP id gd6so14997631lab.3
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 09:43:24 -0800 (PST)
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com. [209.85.215.43])
        by mx.google.com with ESMTPS id jh3si757593lbc.5.2015.01.15.09.43.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 Jan 2015 09:43:23 -0800 (PST)
Received: by mail-la0-f43.google.com with SMTP id s18so14933538lam.2
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 09:43:23 -0800 (PST)
MIME-Version: 1.0
Date: Thu, 15 Jan 2015 12:43:23 -0500
Message-ID: <CANP1eJF77=iH_tm1y0CgF6PwfhUK6WqU9S92d0xAnCt=WhZVfQ@mail.gmail.com>
Subject: [LSF/MM TOPIC] async buffered diskio read for userspace apps
From: Milosz Tanski <milosz@adfin.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>

I would like to talk about enhancing the user interfaces for doing
async buffered disk IO for userspace applications. There's a whole
class of distributed web applications (most new applications today)
that would benefit from such an API. Most of them today rely on
cobbling one together in user space using a threadpool.

The current in kernel AIO interfaces that only support DIRECTIO, they
were generally designed by and for big database vendors. The consensus
is that the current AIO interfaces usually lead to decreased
performance for those app.

I've been developing a new read syscall that allows non-blocking
diskio read (provided that data is in the page cache). It's analogous
to what exists today in the network world with recvmsg with MSG_NOWAIT
flag. The work has been previously described by LWN here:
https://lwn.net/Articles/612483/

Previous attempts (over the last 12+ years) at non-blocking buffered
diskio has stalled due to their complexity. I would like to talk about
the problem, my solution, and get feedback on the course of action.

Over the years I've been building the low level guys of various "web
applications". That usually involves async network based applications
(epoll based servers) and the biggest pain point for the last 8+ years
has been async disk IO.


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
