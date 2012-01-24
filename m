Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 0A4D26B004F
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 13:30:51 -0500 (EST)
Date: Tue, 24 Jan 2012 16:29:09 -0200
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [RFC 1/3] /dev/low_mem_notify
Message-ID: <20120124182909.GB19186@amt.cnet>
References: <CAOJsxLG4hMrAdsyOg6QUe71SPqEBq3eZXvRvaKFZQo8HS1vphQ@mail.gmail.com>
 <84FF21A720B0874AA94B46D76DB982690455978C@008-AM1MPN1-003.mgdnok.nokia.com>
 <4F175706.8000808@redhat.com>
 <alpine.LFD.2.02.1201190922390.3033@tux.localdomain>
 <4F17DCED.4020908@redhat.com>
 <CAOJsxLG3x_R5xq85hh5RvPoD+nhgYbHJfbLW=YMxCZockAXJqw@mail.gmail.com>
 <4F17E058.8020008@redhat.com>
 <84FF21A720B0874AA94B46D76DB9826904559D46@008-AM1MPN1-003.mgdnok.nokia.com>
 <20120124153835.GA10990@amt.cnet>
 <1327421440.13624.30.camel@jaguar>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1327421440.13624.30.camel@jaguar>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: leonid.moiseichuk@nokia.com, rhod@redhat.com, riel@redhat.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, rientjes@google.com, kosaki.motohiro@gmail.com, hannes@cmpxchg.org, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

On Tue, Jan 24, 2012 at 06:10:40PM +0200, Pekka Enberg wrote:
> On Tue, 2012-01-24 at 13:38 -0200, Marcelo Tosatti wrote:
> > Having userspace specify the "sample period" for low memory notification
> > makes no sense. The frequency of notifications is a function of the
> > memory pressure.
> 
> Sure, it makes sense to autotune sample period. I don't see the problem
> with letting userspace decide it for themselves if they want to.
> 
> 			Pekka

Application polls on a file descriptor waiting for asynchronous events,
particular conditions of memory reclaim upon which an action is
necessary.

These signalled conditions are not simply percentages of free memory,
but depend on the amount of freeable cache available, etc. Otherwise
applications could monitor /proc/mem_info and act on that.

What is the point of sampling in the interface as you have it?
Application can read() from the file descriptor to retrieve the current
status, if it wishes.

The objective in this argument is to make the API as simple and easy to
use as possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
