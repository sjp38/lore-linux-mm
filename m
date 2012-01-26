Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 8E24C6B004F
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 11:20:15 -0500 (EST)
Date: Thu, 26 Jan 2012 14:17:58 -0200
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [RFC 1/3] /dev/low_mem_notify
Message-ID: <20120126161758.GA28367@amt.cnet>
References: <4F17DCED.4020908@redhat.com>
 <CAOJsxLG3x_R5xq85hh5RvPoD+nhgYbHJfbLW=YMxCZockAXJqw@mail.gmail.com>
 <4F17E058.8020008@redhat.com>
 <84FF21A720B0874AA94B46D76DB9826904559D46@008-AM1MPN1-003.mgdnok.nokia.com>
 <20120124153835.GA10990@amt.cnet>
 <4F1ED77F.4090900@redhat.com>
 <20120124181034.GA19186@amt.cnet>
 <4F1FC2C8.10103@redhat.com>
 <20120125101209.GB29167@amt.cnet>
 <4F1FDDE2.9050609@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F1FDDE2.9050609@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ronen Hod <rhod@redhat.com>
Cc: leonid.moiseichuk@nokia.com, penberg@kernel.org, riel@redhat.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, rientjes@google.com, kosaki.motohiro@gmail.com, hannes@cmpxchg.org, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

> >it should free for each notification received, that is, its part?
> >
> >Its easier if there is a goal, a hint of how many pages the process
> >should release.
> 
> I have to agree.
> Still, the amount of memory that an app should free per memory-pressure-level can be best calculated inside the application (based on comfortable_free_pages relative to process RSS, as you suggested).

It is easier if the kernel calculates the target (the application is
free to ignore the hint, of course), because it depends on information 
not readily available in userspace.

>  Fairness is also an issue.
> And, if in the meantime the memory pressure ended, would you recommend that the application will continue with its work?

There appears to be interest in an event to notify that higher levels
of memory are available (see Leonid's email).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
