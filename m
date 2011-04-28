Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 936356B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 06:09:45 -0400 (EDT)
Received: by fxm18 with SMTP id 18so2495161fxm.14
        for <linux-mm@kvack.org>; Thu, 28 Apr 2011 03:09:42 -0700 (PDT)
Date: Thu, 28 Apr 2011 12:09:38 +0200
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
Message-ID: <20110428100938.GA10721@htj.dyndns.org>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1303961284.3981.318.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Christoph Lameter <cl@linux.com>, Eric Dumazet <eric.dumazet@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hey,

On Thu, Apr 28, 2011 at 11:28:04AM +0800, Shaohua Li wrote:
> > Okay, this communication failure isn't my fault.  Please re-read what
> > I wrote before, my concern wasn't primarily about pathological worst
> > case - if that many concurrent updates are happening && the counter
> > needs to be accurate, it can't even use atomic counter.  It should be
> > doing full exclusion around the counter and the associated operation
> > _together_.
> > 
> > I'm worried about sporadic erratic behavior happening regardless of
> > update frequency and preemption would contribute but isn't necessary
> > for that to happen.
>
> Ok, I misunderstood the mail you sent to Christoph, sorry. So you have
> no problem about the atomic convert. I'll update the patch against base
> tree, given the preemptless patch has problem.

Hmm... we're now more lost than ever. :-( Can you please re-read my
message two replies ago?  The one where I talked about sporadic
erratic behaviors in length and why I was worried about it.

In your last reply, you talked about preemption and that you didn't
have problems with disabling preemption, which, unfortunately, doesn't
have much to do with my concern with the sporadic erratic behaviors
and that's what I pointed out in my previous reply.  So, it doesn't
feel like anything is resolved.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
