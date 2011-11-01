Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 424796B0069
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 11:59:53 -0400 (EDT)
Received: by ywa17 with SMTP id 17so9423307ywa.14
        for <linux-mm@kvack.org>; Tue, 01 Nov 2011 08:59:51 -0700 (PDT)
Date: Tue, 1 Nov 2011 08:59:45 -0700
From: Tejun Heo <htejun@gmail.com>
Subject: Re: Issue with core dump
Message-ID: <20111101155945.GQ18855@google.com>
References: <CAGr+u+zkPiZpGefstcbJv_cj929icWKXbqFy1uR22Hns1hzFeQ@mail.gmail.com>
 <20111101152320.GA30466@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111101152320.GA30466@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: trisha yad <trisha1march@gmail.com>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, rientjes@google.com, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rusty Russell <rusty@rustcorp.com.au>

Hello,

On Tue, Nov 01, 2011 at 04:23:20PM +0100, Oleg Nesterov wrote:
> Whatever we do, we can't "stop" other threads at the time when
> thread 'a' traps. All we can do is to try to shrink the window.

Yeah, "at the time" can't even be defined preciesly.  Order of
operation isn't clearly defined in absence of synchronization
constructs.  In the described example, there's unspecified amount of
time (or cycles rather) between the load of the global variable and
the thread faulting.  Anything could have happened inbetween no matter
how immediate core dump was.

As long as we're reasonably immediate, which I think we already are, I
don't think there's much which needs to be changed.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
