Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id F24AE900001
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 04:19:34 -0400 (EDT)
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20110428100938.GA10721@htj.dyndns.org>
References: <20110421180159.GF15988@htj.dyndns.org>
	 <alpine.DEB.2.00.1104211308300.5741@router.home>
	 <20110421183727.GG15988@htj.dyndns.org>
	 <alpine.DEB.2.00.1104211350310.5741@router.home>
	 <20110421190807.GK15988@htj.dyndns.org>
	 <1303439580.3981.241.camel@sli10-conroe>
	 <20110426121011.GD878@htj.dyndns.org>
	 <1303883009.3981.316.camel@sli10-conroe>
	 <20110427102034.GE31015@htj.dyndns.org>
	 <1303961284.3981.318.camel@sli10-conroe>
	 <20110428100938.GA10721@htj.dyndns.org>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 29 Apr 2011 16:19:31 +0800
Message-ID: <1304065171.3981.594.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Eric Dumazet <eric.dumazet@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi,
On Thu, 2011-04-28 at 18:09 +0800, Tejun Heo wrote:
> On Thu, Apr 28, 2011 at 11:28:04AM +0800, Shaohua Li wrote:
> > > Okay, this communication failure isn't my fault.  Please re-read what
> > > I wrote before, my concern wasn't primarily about pathological worst
> > > case - if that many concurrent updates are happening && the counter
> > > needs to be accurate, it can't even use atomic counter.  It should be
> > > doing full exclusion around the counter and the associated operation
> > > _together_.
> > > 
> > > I'm worried about sporadic erratic behavior happening regardless of
> > > update frequency and preemption would contribute but isn't necessary
> > > for that to happen.
> >
> > Ok, I misunderstood the mail you sent to Christoph, sorry. So you have
> > no problem about the atomic convert. I'll update the patch against base
> > tree, given the preemptless patch has problem.
> 
> Hmm... we're now more lost than ever. :-( Can you please re-read my
> message two replies ago?  The one where I talked about sporadic
> erratic behaviors in length and why I was worried about it.
> 
> In your last reply, you talked about preemption and that you didn't
> have problems with disabling preemption, which, unfortunately, doesn't
> have much to do with my concern with the sporadic erratic behaviors
> and that's what I pointed out in my previous reply.  So, it doesn't
> feel like anything is resolved.
ok, I got your point. I'd agree there is sporadic erratic behaviors, but
I expect there is no problem here. We all agree the worst case is the
same before/after the change. Any program should be able to handle the
worst case, otherwise the program itself is buggy. Discussing a buggy
program is meaningless. After the change, something behavior is changed,
but the worst case isn't. So I don't think this is a big problem.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
