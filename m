Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 20BF48D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 04:59:47 -0400 (EDT)
Message-ID: <4D919F75.5070601@redhat.com>
Date: Tue, 29 Mar 2011 10:59:33 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: Very aggressive memory reclaim
References: <AANLkTinFqqmE+fTMTLVU-_CwPE+LQv7CpXSQ5+CdAKLK@mail.gmail.com>	<20110328215344.GC3008@dastard> <AANLkTi==vw7Dy-oK31PxHadwUaDRUUk+TM0ECSZ=chfv@mail.gmail.com>
In-Reply-To: <AANLkTi==vw7Dy-oK31PxHadwUaDRUUk+TM0ECSZ=chfv@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Lepikhin <johnlepikhin@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, linux-mm@kvack.org

On 03/29/2011 09:26 AM, John Lepikhin wrote:
> 2011/3/29 Dave Chinner<david@fromorbit.com>:
>
> >  First it would be useful to determine why the VM is reclaiming so
> >  much memory. If it is somewhat predictable when the excessive
> >  reclaim is going to happen, it might be worth capturing an event
> >  trace from the VM so we can see more precisely what it is doiing
> >  during this event. In that case, recording the kmem/* and vmscan/*
> >  events is probably sufficient to tell us what memory allocations
> >  triggered reclaim and how much reclaim was done on each event.
>
> Do you mean I must add some debug to mm functions? I don't know any
> other way to catch such events.

Download and build trace-cmd 
(git://git.kernel.org/pub/scm/linux/kernel/git/rostedt/trace-cmd.git), 
and do

$ trace-cmd record -e kmem -e vmscan -b 30000

Hit ctrl-C when done and post the output file generated in cwd.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
