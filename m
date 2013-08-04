Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 4C3476B0031
	for <linux-mm@kvack.org>; Sun,  4 Aug 2013 19:49:32 -0400 (EDT)
Date: Mon, 5 Aug 2013 08:50:11 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Possible deadloop in direct reclaim?
Message-ID: <20130804235011.GH32486@bbox>
References: <89813612683626448B837EE5A0B6A7CB3B62F8F272@SC-VEXCH4.marvell.com>
 <000001400d38469d-a121fb96-4483-483a-9d3e-fc552e413892-000000@email.amazonses.com>
 <89813612683626448B837EE5A0B6A7CB3B62F8F5C3@SC-VEXCH4.marvell.com>
 <CAHGf_=q8JZQ42R-3yzie7DXUEq8kU+TZXgcX9s=dn8nVigXv8g@mail.gmail.com>
 <89813612683626448B837EE5A0B6A7CB3B62F8FE33@SC-VEXCH4.marvell.com>
 <51F69BD7.2060407@gmail.com>
 <89813612683626448B837EE5A0B6A7CB3B630BDF99@SC-VEXCH4.marvell.com>
 <51F9CBC0.2020006@gmail.com>
 <51F9E265.7030503@oracle.com>
 <51FD7483.5060504@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51FD7483.5060504@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Bob Liu <bob.liu@oracle.com>, Lisa Du <cldu@marvell.com>, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Bob Liu <lliubbo@gmail.com>

Hi KOSAKI,

On Sat, Aug 03, 2013 at 05:22:11PM -0400, KOSAKI Motohiro wrote:
> (8/1/13 12:21 AM), Bob Liu wrote:
> >Hi KOSAKI,
> >
> >On 08/01/2013 10:45 AM, KOSAKI Motohiro wrote:
> >
> >>
> >>Please read more older code. Your pointed code is temporary change and I
> >>changed back for fixing
> >>bugs.
> >>If you look at the status in middle direct reclaim, we can't avoid race
> >>condition from multi direct
> >>reclaim issues. Moreover, if kswapd doesn't awaken, it is a problem.
> >>This is a reason why current code
> >>behave as you described.
> >>I agree we should fix your issue as far as possible. But I can't agree
> >>your analysis.
> >>
> >
> >I found this thread:
> >mm, vmscan: fix do_try_to_free_pages() livelock
> >https://lkml.org/lkml/2012/6/14/74
> >
> >I think that's the same issue Lisa met.
> >
> >But I didn't find out why your patch didn't get merged?
> >There were already many acks.
> 
> Just because I misunderstood the patch has already been merged. OK, I'll
> resend this.

Just FYI,
Now Lisa am working on it and have a plan to resend more concrete
description based on your old version.

Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
