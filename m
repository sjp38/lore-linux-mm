Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 0170E900018
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 16:16:18 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id b13so12424524wgh.11
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 13:16:17 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j16si24777367wic.43.2014.11.11.13.16.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Nov 2014 13:16:17 -0800 (PST)
Date: Tue, 11 Nov 2014 22:16:15 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [BUG] mm/page-writeback.c: divide by zero in pos_ratio_polynom
 not fixed
Message-ID: <20141111211615.GE32298@quack.suse.cz>
References: <20141101082325.7be0463f@gandalf.local.home>
 <20141111201539.GA12333@quack.suse.cz>
 <20141111160448.61354836@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141111160448.61354836@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>

On Tue 11-11-14 16:04:48, Steven Rostedt wrote:
> On Tue, 11 Nov 2014 21:15:39 +0100
> Jan Kara <jack@suse.cz> wrote:
> 
> 
> >   So I was looking into this but I have to say I don't understand where is
> > the problem. The registers clearly show that x_intercept - bdi_setpoint + 1
> > == 0 (in 32-bit arithmetics). Given:
> >    x_intercept = bdi_setpoint + span
> > 
> > We have that span + 1 == 0 and that means that:
> > ((thresh - bdi_thresh + 8 * write_bw) * (u64)x >> 16) == -1 (again in
> > 32-bit arithmetics). But I don't see how that can realistically happen...
> > 
> > Is this reproducible at all?
> > 
> 
> Unfortunately not. It only happened once, and I haven't been able to
> reproduce it again.
  BTW, how much memory does the machine have and what is
/proc/sys/vm/dirty_ratio and /proc/sys/vm/dirty_background_ratio (or
corresponding dirty_bytes, dirty_background_bytes if you are using them)?

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
