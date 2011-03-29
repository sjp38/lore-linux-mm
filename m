Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A1C0D8D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 19:12:07 -0400 (EDT)
Date: Wed, 30 Mar 2011 01:12:00 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Lsf] [LSF][MM] page allocation & direct reclaim latency
Message-ID: <20110329231200.GQ12265@random.random>
References: <1301373398.2590.20.camel@mulgrave.site>
 <4D91FC2D.4090602@redhat.com>
 <20110329190520.GJ12265@random.random>
 <BANLkTikDwfQaSGtrKOSvgA9oaRC1Lbx3cw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTikDwfQaSGtrKOSvgA9oaRC1Lbx3cw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Rik van Riel <riel@redhat.com>, lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Wed, Mar 30, 2011 at 07:13:42AM +0900, Minchan Kim wrote:
> It's okay to me. LRU ordering issue wouldn't take much time.
> But I am not sure Mel would have a long time. :)
> 
> About reclaim latency, I sent a patch in the old days.
> http://marc.info/?l=linux-mm&m=129187231129887&w=4
> 
> And some guys on embedded had a concern about latency.
> They want OOM rather than eviction of working set and undeterministic
> latency of reclaim.
> 
> As another issue of related to latency, there is a OOM.
> To accelerate task's exit, we raise a priority of the victim process
> but it had a problem so Kosaki decided reverting the patch. It's
> totally related to latency issue but it would
> 
> In addition, Kame and I sent a patch to prevent forkbomb. Kame's
> apprach is to track the history of mm and mine is to use sysrq to kill
> recently created tasks. The approaches have pros and cons.
> But anyone seem to not has a interest about forkbomb protection.
> So I want to listen other's opinion we really need it

The sysrq won't help on large servers, virtual clouds or android
devices where there's no keyboard attached and not sysrqd running. So
I'd prefer not requiring sysrq for that, even if you can run a sysrq,
few people would know how to activate an obscure sysrq feature meant
to be more selective than SYSRQ+I (or SYSRQ+B..) for forkbombs, if it
works without human intervention I think it's more valuable.

> I am not sure this could become a topic of LSF/MM

Now the forkbomb detection would fit nicely as a subtopic into Hugh's
OOM topic. I found one more spare MM slot on 5 April 12:30-13, so for
now I filled it with OOM and forkbomb.

> If it is proper, I would like to talk above issues in "Reclaim,
> compaction and LRU ordering" slot.

Sounds good to me. I added "allocation latency" to your slot.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
