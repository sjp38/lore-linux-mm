Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 82109900001
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 10:25:13 -0400 (EDT)
Date: Fri, 29 Apr 2011 09:25:09 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
In-Reply-To: <20110429141817.GN16552@htj.dyndns.org>
Message-ID: <alpine.DEB.2.00.1104290923560.7776@router.home>
References: <20110421190807.GK15988@htj.dyndns.org> <1303439580.3981.241.camel@sli10-conroe> <20110426121011.GD878@htj.dyndns.org> <1303883009.3981.316.camel@sli10-conroe> <20110427102034.GE31015@htj.dyndns.org> <1303961284.3981.318.camel@sli10-conroe>
 <20110428100938.GA10721@htj.dyndns.org> <1304065171.3981.594.camel@sli10-conroe> <20110429084424.GJ16552@htj.dyndns.org> <alpine.DEB.2.00.1104290855060.7776@router.home> <20110429141817.GN16552@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Shaohua Li <shaohua.li@intel.com>, Eric Dumazet <eric.dumazet@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, 29 Apr 2011, Tejun Heo wrote:

> > If someone wants more accuracy then we need the ability to dynamically set
> > the batch limit similar to what the vm statistics do.
>
> So, if you can remove _sum() by doing the above without introducing
> excessive complexity or penalizing use cases which might not have too
> much commonality with vmstat, by all means, but please pay attention
> to the current users.  Actually take a look at them.

I am content to be maintaining the vm statistics.... But Shaohua may want
to have a look at it?

> Also, if someone is gonna put considerable amount of effort into it,
> please also invest some time into showing actual performance benefits,
> or at least possibility of actual benefits.

Yes. I think Shaohua already has some tests that could use some
improving. So we have kind of an agreement on how to move forward?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
