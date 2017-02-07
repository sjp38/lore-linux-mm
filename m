Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 506FF6B0253
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 07:48:39 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r18so25218185wmd.1
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 04:48:39 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a206si12063037wmh.55.2017.02.07.04.48.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 04:48:38 -0800 (PST)
Date: Tue, 7 Feb 2017 13:48:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
Message-ID: <20170207124835.GP5065@dhcp22.suse.cz>
References: <20170206220530.apvuknbagaf2rdlw@techsingularity.net>
 <20170207084855.GC5065@dhcp22.suse.cz>
 <20170207094300.cuxfqi35wflk5nr5@techsingularity.net>
 <2cdef192-1939-d692-1224-8ff7d7ff7203@suse.cz>
 <20170207102809.awh22urqmfrav5r6@techsingularity.net>
 <20170207103552.GH5065@dhcp22.suse.cz>
 <20170207113435.6xthczxt2cx23r4t@techsingularity.net>
 <20170207114327.GI5065@dhcp22.suse.cz>
 <20170207123708.GO5065@dhcp22.suse.cz>
 <0bbc50c4-b18a-a510-ba75-4d7415f15e82@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0bbc50c4-b18a-a510-ba75-4d7415f15e82@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>, Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue 07-02-17 13:43:39, Vlastimil Babka wrote:
[...]
> > Anyway, shouldn't be it sufficient to disable preemption
> > on drain_local_pages_wq? The CPU hotplug callback will not preempt us
> > and so we cannot work on the same cpus, right?
> 
> I thought the problem here was that the callback races with the work item
> that has been migrated to a different cpu. Once we are not working on the
> local cpu, disabling preempt/irq's won't help?

If the worker is racing with the callback than only one of can run on a
_particular_ cpu. So they cannot race. Or am I missing something?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
