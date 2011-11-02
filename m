Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1717A6B0069
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 07:30:56 -0400 (EDT)
Date: Wed, 2 Nov 2011 11:30:31 +0000
From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: Issue with core dump
Message-ID: <20111102113030.GE22462@linux-mips.org>
References: <CAGr+u+zkPiZpGefstcbJv_cj929icWKXbqFy1uR22Hns1hzFeQ@mail.gmail.com>
 <20111101152320.GA30466@redhat.com>
 <CAGr+u+wgAYVWgdcG6o+6F0mDzuyNzoOxvsFwq0dMsR3JNnZ-cA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGr+u+wgAYVWgdcG6o+6F0mDzuyNzoOxvsFwq0dMsR3JNnZ-cA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: trisha yad <trisha1march@gmail.com>
Cc: Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, rientjes@google.com, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rusty Russell <rusty@rustcorp.com.au>, Tejun Heo <htejun@gmail.com>

On Wed, Nov 02, 2011 at 12:03:39PM +0530, trisha yad wrote:

> Thanks all for your answer.
> 
> In loaded embedded system the time at with code hit do_user_fault()
> and core_dump_wait() is bit
> high, I check on my  system it took 2.7 sec. so it is very much
> possible that core dump is not correct.
> It  contain global value updated.
> 
> So is it possible at time of send_signal() we can stop modification of
> faulty thread memory ?

On existing hardware it is impossible to take a consistent snapshot of a
multi-threaded application at the time of one thread faulting.

A software simulator can handle this sort of race condition but of course
this approach has other disadvantages.

  Ralf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
