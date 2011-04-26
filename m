Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id CB7909000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 15:02:14 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p3QJ2BDS002475
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 12:02:11 -0700
Received: from iwc10 (iwc10.prod.google.com [10.241.65.138])
	by wpaz5.hot.corp.google.com with ESMTP id p3QJ296g028572
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 12:02:10 -0700
Received: by iwc10 with SMTP id 10so788252iwc.10
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 12:02:09 -0700 (PDT)
Date: Tue, 26 Apr 2011 12:02:15 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
In-Reply-To: <20110426121011.GD878@htj.dyndns.org>
Message-ID: <alpine.LSU.2.00.1104261140010.9169@sister.anvils>
References: <alpine.DEB.2.00.1104180930580.23207@router.home> <20110421144300.GA22898@htj.dyndns.org> <20110421145837.GB22898@htj.dyndns.org> <alpine.DEB.2.00.1104211243350.5741@router.home> <20110421180159.GF15988@htj.dyndns.org> <alpine.DEB.2.00.1104211308300.5741@router.home>
 <20110421183727.GG15988@htj.dyndns.org> <alpine.DEB.2.00.1104211350310.5741@router.home> <20110421190807.GK15988@htj.dyndns.org> <1303439580.3981.241.camel@sli10-conroe> <20110426121011.GD878@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Shaohua Li <shaohua.li@intel.com>, Christoph Lameter <cl@linux.com>, Eric Dumazet <eric.dumazet@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, 26 Apr 2011, Tejun Heo wrote:
> 
> However, after the change, especially with high @batch count, the
> result may deviate significantly even with low frequency concurrent
> updates.  @batch deviations won't happen often but will happen once in
> a while, which is just nasty and makes the API much less useful and
> those occasional deviations can cause sporadic erratic behaviors -
> e.g. filesystems use it for free block accounting.  It's actually used
> for somewhat critical decision making.

This worried me a little when the percpu block counting went into tmpfs,
though it's not really critical there.

Would it be feasible, with these counters that are used against limits,
to have an adaptive batching scheme such that the batches get smaller
and smaller, down to 1 and to 0, as the total approaches the limit?
(Of course a single global percpu_counter_batch won't do for this.)

Perhaps it's a demonstrable logical impossibility, perhaps it would
slow down the fast (far from limit) path more than we can afford,
perhaps I haven't read enough of this thread and I'm taking it
off-topic.  Forgive me if so.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
