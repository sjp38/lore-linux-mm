Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 58B9E6B00EE
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 11:33:34 -0400 (EDT)
From: "Shi, Alex" <alex.shi@intel.com>
Date: Fri, 29 Jul 2011 23:33:26 +0800
Subject: RE: [PATCH] kswapd: assign new_order and new_classzone_idx after
 wakeup in sleeping
Message-ID: <6E3BC7F7C9A4BF4286DD4C043110F30B5B69FE1A4F@shsmsx502.ccr.corp.intel.com>
References: <1311903282-8539-1-git-send-email-alex.shi@intel.com>
 <20110729085717.GC1843@barrios-desktop>
In-Reply-To: <20110729085717.GC1843@barrios-desktop>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "P@draigBrady.com" <P@draigBrady.com>, "mgorman@suse.de" <mgorman@suse.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "andrea@cpushare.com" <andrea@cpushare.com>, "Chen, Tim C" <tim.c.chen@intel.com>, "Li, Shaohua" <shaohua.li@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "riel@redhat.com" <riel@redhat.com>, "luto@mit.edu" <luto@mit.edu>

> -----Original Message-----
> From: Minchan Kim [mailto:minchan.kim@gmail.com]
> Sent: Friday, July 29, 2011 4:57 PM
> To: Shi, Alex
> Cc: majordomo@kvack.org; P@draigBrady.com; mgorman@suse.de;
> linux-kernel@vger.kernel.org; andrea@cpushare.com; Chen, Tim C; Li,
> Shaohua; akpm@linux-foundation.org; riel@redhat.com; luto@mit.edu
> Subject: Re: [PATCH] kswapd: assign new_order and new_classzone_idx after
> wakeup in sleeping
>=20
> On Fri, Jul 29, 2011 at 09:34:42AM +0800, Alex Shi wrote:
> > There 2 place to read pgdat in kswapd. One is return from a successful
> > balance, another is waked up from sleeping. But the new_order and
> > new_classzone_idx are not assigned after kswapd_try_to_sleep(), that
> > will cause a bug in the following scenario.
> >
> > After the last time successful balance, kswapd goes to sleep. So the
> > new_order and new_classzone_idx were assigned to 0 and MAX-1 since ther=
e
> > is no new wakeup during last time balancing. Now, a new wakeup came and
> > finish balancing successful with order > 0. But since new_order is stil=
l
> > 0, this time successful balancing were judged as a failed balance. so,
> > if there is another new wakeup coming during balancing, kswapd cann't
> > read this and still want to try to sleep. And if the new wakeup is a
> > tighter request, kswapd may goes to sleep, not to do balancing. That is
> > incorrect.
> >
> > So, to avoid above problem, the new_order and new_classzone_idx need to
> > be assigned for later successful comparison.
> >
> > Paidrag Brady, Could like do a retry for your problem on this patch?
> >
> > Signed-off-by: Alex Shi <alex.shi@intel.com>
> > Acked-by: Mel Gorman <mgorman@suse.de>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Thanks for review.=20
BTW, I remove the incorrect email address of linux-mm. sorry for this!=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
