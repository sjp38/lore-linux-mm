Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0FD6D6B0032
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 17:32:04 -0500 (EST)
Received: by mail-we0-f180.google.com with SMTP id w62so17306145wes.11
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 14:32:03 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id uq6si5305842wjc.12.2015.01.15.14.32.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 Jan 2015 14:32:02 -0800 (PST)
Date: Thu, 15 Jan 2015 23:31:57 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] async buffered diskio read for userspace
 apps
Message-ID: <20150115223157.GB25884@quack.suse.cz>
References: <CANP1eJF77=iH_tm1y0CgF6PwfhUK6WqU9S92d0xAnCt=WhZVfQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANP1eJF77=iH_tm1y0CgF6PwfhUK6WqU9S92d0xAnCt=WhZVfQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Milosz Tanski <milosz@adfin.com>
Cc: lsf-pc@lists.linux-foundation.org, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>

On Thu 15-01-15 12:43:23, Milosz Tanski wrote:
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
> 
> Over the years I've been building the low level guys of various "web
> applications". That usually involves async network based applications
> (epoll based servers) and the biggest pain point for the last 8+ years
> has been async disk IO.
  Maybe this topic will be sorted out before LSF/MM. I know Andrew had some
objections about doc and was suggesting a solution using fincore() (which
Christoph refuted as being racy). Also there was a pending question
regarding whether the async read in this form will be used by applications.
But if it doesn't get sorted out a short session on the pending issues
would be probably useful.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
