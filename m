Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 623B16B0038
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 12:58:57 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id v96so70063910ioi.5
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 09:58:57 -0800 (PST)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id l20si1580183itb.30.2017.02.10.09.58.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Feb 2017 09:58:55 -0800 (PST)
Date: Fri, 10 Feb 2017 11:58:52 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
In-Reply-To: <20170209191547.GA31906@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1702101154480.29784@east.gentwo.org>
References: <20170208152106.GP5686@dhcp22.suse.cz> <alpine.DEB.2.20.1702081011460.4938@east.gentwo.org> <alpine.DEB.2.20.1702081838560.3536@nanos> <alpine.DEB.2.20.1702082109530.13608@east.gentwo.org> <alpine.DEB.2.20.1702091240000.3604@nanos>
 <alpine.DEB.2.20.1702090759370.22559@east.gentwo.org> <alpine.DEB.2.20.1702091548300.3604@nanos> <alpine.DEB.2.20.1702090940190.23960@east.gentwo.org> <alpine.DEB.2.20.1702091708270.3604@nanos> <alpine.DEB.2.20.1702091048330.24346@east.gentwo.org>
 <20170209191547.GA31906@dhcp22.suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 9 Feb 2017, Michal Hocko wrote:

> Christoph, you are completely ignoring the reality and the code. There
> is no need for stop_machine nor it is helping anything. As the matter
> of fact there is a synchronization with the cpu hotplug needed if you
> want to make a per-cpu specific operations. get_online_cpus is the
> most straightforward and heavy weight way to do this synchronization
> but not the only one. As the patch [1] describes we do not really need
> get_online_cpus in drain_all_pages because we can do _better_. But
> this is not in any way a generic thing applicable to other code paths.
>
> If you disagree then you are free to post patches but hand waving you
> are doing here is just wasting everybody's time. So please cut it here
> unless you have specific proposals to improve the current situation.

I am fine with the particular solution here for this particular problem.

My problem is the general way of having to synchronize via
get_online_cpus() because of cpu hotplug operations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
