Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 0B5626B13F2
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 05:30:26 -0500 (EST)
Date: Mon, 6 Feb 2012 11:30:24 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [Lsf-pc] [ATTEND] LSF/MM conference
Message-ID: <20120206103024.GA6890@quack.suse.cz>
References: <CANN689EAfiTdXSr8L+UTWxJLEGHeLVziNLCsdbLuqzsVdERexg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANN689EAfiTdXSr8L+UTWxJLEGHeLVziNLCsdbLuqzsVdERexg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>

  Hello,

On Mon 06-02-12 00:14:58, Michel Lespinasse wrote:
> I would like to attend the LSF/MM summit in April this year. I do not
> have any formal topic proposals at this point; however there are
> several MM areas I am interested in:
> 
> - mmap_sem locking: I have done some work in the past to reduce
> mmap_sem hold times when page faults wait for transfering file pages
> from disk, as well as during large mlock operations. However mmap_sem
> can still be held for long times today when write page faults trigger
> dirty write throttling, or when the system is under memory pressure
> and page allocations within the page fault handler hit the ttfp path
> (I have some pending work in these areas that I'd like to submit
> shortly). This is an area that hasn't been much invested in, probably
> because the fact that most users only need a read lock suffices to
> mask the issues in many cases. However I expect it to become more
> important as we keep improving performance isolation between
> processes. One way we frequently hit mmap_sem related issues at Google
> is when building monitoring mechanisms that are expected to stay
> responsive when the monitored systems get into bad memory pressure
> situations.
  I'd be interested in this. Holding mmap_sem during write page faults
(->page_mkwrite) is causing problems with lock ordering when handling
filesystem freezing. I hope I can solve the problems by dropping mmap_sem
when we see filesystem is frozen, wait for it to thaw, retake mmap_sem and
return VM_FAULT_RETRY but I'd be happy for a less hacky solution...

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
