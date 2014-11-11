Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 384B4900014
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 16:05:00 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id lj1so11290724pab.22
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 13:05:00 -0800 (PST)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.226])
        by mx.google.com with ESMTP id au4si20902864pbd.174.2014.11.11.13.04.58
        for <linux-mm@kvack.org>;
        Tue, 11 Nov 2014 13:04:58 -0800 (PST)
Date: Tue, 11 Nov 2014 16:04:48 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [BUG] mm/page-writeback.c: divide by zero in pos_ratio_polynom
 not fixed
Message-ID: <20141111160448.61354836@gandalf.local.home>
In-Reply-To: <20141111201539.GA12333@quack.suse.cz>
References: <20141101082325.7be0463f@gandalf.local.home>
	<20141111201539.GA12333@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 11 Nov 2014 21:15:39 +0100
Jan Kara <jack@suse.cz> wrote:


>   So I was looking into this but I have to say I don't understand where is
> the problem. The registers clearly show that x_intercept - bdi_setpoint + 1
> == 0 (in 32-bit arithmetics). Given:
>    x_intercept = bdi_setpoint + span
> 
> We have that span + 1 == 0 and that means that:
> ((thresh - bdi_thresh + 8 * write_bw) * (u64)x >> 16) == -1 (again in
> 32-bit arithmetics). But I don't see how that can realistically happen...
> 
> Is this reproducible at all?
> 

Unfortunately not. It only happened once, and I haven't been able to
reproduce it again.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
