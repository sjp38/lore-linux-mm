Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 122456B0005
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 10:17:12 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id l2-v6so5828172ybk.17
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 07:17:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y8-v6sor779452ybj.33.2018.04.10.07.17.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Apr 2018 07:17:10 -0700 (PDT)
Date: Tue, 10 Apr 2018 07:17:07 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC] mm, slab: reschedule cache_reap() on the same CPU
Message-ID: <20180410141707.GL3126663@devbig577.frc2.facebook.com>
References: <20180410081531.18053-1-vbabka@suse.cz>
 <alpine.DEB.2.20.1804100907160.27333@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1804100907160.27333@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, John Stultz <john.stultz@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Stephen Boyd <sboyd@kernel.org>

On Tue, Apr 10, 2018 at 09:12:08AM -0500, Christopher Lameter wrote:
> > @@ -4074,7 +4086,8 @@ static void cache_reap(struct work_struct *w)
> >  	next_reap_node();
> >  out:
> >  	/* Set up the next iteration */
> > -	schedule_delayed_work(work, round_jiffies_relative(REAPTIMEOUT_AC));
> > +	schedule_delayed_work_on(reap_work->cpu, work,
> > +					round_jiffies_relative(REAPTIMEOUT_AC));
> 
> schedule_delayed_work_on(smp_processor_id(), work, round_jiffies_relative(REAPTIMEOUT_AC));
> 
> instead all of the other changes?

Yeah, that'd make more sense.

Thanks.

-- 
tejun
