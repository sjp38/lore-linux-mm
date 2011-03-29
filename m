Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id ED45F8D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 03:26:03 -0400 (EDT)
Received: by wyf19 with SMTP id 19so4524249wyf.14
        for <linux-mm@kvack.org>; Tue, 29 Mar 2011 00:26:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110328215344.GC3008@dastard>
References: <AANLkTinFqqmE+fTMTLVU-_CwPE+LQv7CpXSQ5+CdAKLK@mail.gmail.com>
	<20110328215344.GC3008@dastard>
Date: Tue, 29 Mar 2011 11:26:00 +0400
Message-ID: <AANLkTi==vw7Dy-oK31PxHadwUaDRUUk+TM0ECSZ=chfv@mail.gmail.com>
Subject: Re: Very aggressive memory reclaim
From: John Lepikhin <johnlepikhin@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, xfs@oss.sgi.com, linux-mm@kvack.org

2011/3/29 Dave Chinner <david@fromorbit.com>:

> First it would be useful to determine why the VM is reclaiming so
> much memory. If it is somewhat predictable when the excessive
> reclaim is going to happen, it might be worth capturing an event
> trace from the VM so we can see more precisely what it is doiing
> during this event. In that case, recording the kmem/* and vmscan/*
> events is probably sufficient to tell us what memory allocations
> triggered reclaim and how much reclaim was done on each event.

Do you mean I must add some debug to mm functions? I don't know any
other way to catch such events.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
