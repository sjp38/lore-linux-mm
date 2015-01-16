Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1674C6B0032
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 11:55:11 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kq14so25281308pab.6
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 08:55:10 -0800 (PST)
Received: from mail.samba.org (fn.samba.org. [2001:470:1f05:1a07::1])
        by mx.google.com with ESMTPS id dt7si6173707pdb.77.2015.01.16.08.55.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 16 Jan 2015 08:55:09 -0800 (PST)
Date: Fri, 16 Jan 2015 08:55:06 -0800
From: Jeremy Allison <jra@samba.org>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] async buffered diskio read for userspace
 apps
Message-ID: <20150116165506.GA10856@samba2>
Reply-To: Jeremy Allison <jra@samba.org>
References: <CANP1eJF77=iH_tm1y0CgF6PwfhUK6WqU9S92d0xAnCt=WhZVfQ@mail.gmail.com>
 <20150115223157.GB25884@quack.suse.cz>
 <CANP1eJGRX4w56Ek4j7d2U+F7GNWp6RyOJonxKxTy0phUCpBM9g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANP1eJGRX4w56Ek4j7d2U+F7GNWp6RyOJonxKxTy0phUCpBM9g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Milosz Tanski <milosz@adfin.com>
Cc: Jan Kara <jack@suse.cz>, lsf-pc@lists.linux-foundation.org, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>

On Fri, Jan 16, 2015 at 10:44:12AM -0500, Milosz Tanski wrote:
> On Thu, Jan 15, 2015 at 5:31 PM, Jan Kara <jack@suse.cz> wrote:
> > On Thu 15-01-15 12:43:23, Milosz Tanski wrote:
> >> I would like to talk about enhancing the user interfaces for doing
> >> async buffered disk IO for userspace applications. There's a whole
> >> class of distributed web applications (most new applications today)
> >> that would benefit from such an API. Most of them today rely on
> >> cobbling one together in user space using a threadpool.
> >>
> >> The current in kernel AIO interfaces that only support DIRECTIO, they
> >> were generally designed by and for big database vendors. The consensus
> >> is that the current AIO interfaces usually lead to decreased
> >> performance for those app.
> >>
> >> I've been developing a new read syscall that allows non-blocking
> >> diskio read (provided that data is in the page cache). It's analogous
> >> to what exists today in the network world with recvmsg with MSG_NOWAIT
> >> flag. The work has been previously described by LWN here:
> >> https://lwn.net/Articles/612483/
> >>
> >> Previous attempts (over the last 12+ years) at non-blocking buffered
> >> diskio has stalled due to their complexity. I would like to talk about
> >> the problem, my solution, and get feedback on the course of action.
> >>
> >> Over the years I've been building the low level guys of various "web
> >> applications". That usually involves async network based applications
> >> (epoll based servers) and the biggest pain point for the last 8+ years
> >> has been async disk IO.
> >   Maybe this topic will be sorted out before LSF/MM. I know Andrew had some
> > objections about doc and was suggesting a solution using fincore() (which
> > Christoph refuted as being racy). Also there was a pending question
> > regarding whether the async read in this form will be used by applications.
> > But if it doesn't get sorted out a short session on the pending issues
> > would be probably useful.
> >
> >                                                                 Honza
> > --
> > Jan Kara <jack@suse.cz>
> > SUSE Labs, CR
> 
> I've spent the better part of yesterday wrapping up the first cut of
> samba support to FIO so we can test a modified samba file server with
> these changes in a few scenarios. Right now it's only sync but I hope
> to have async in the future. I hope that by the time the summit rolls
> around I'll have data to share from samba and maybe some other common
> apps (node.js / twisted).

Don't forget to share the code changes :-). We @ Samba would
love to see them to keep track !

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
