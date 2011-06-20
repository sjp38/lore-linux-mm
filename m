Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C927E6B0012
	for <linux-mm@kvack.org>; Sun, 19 Jun 2011 20:53:25 -0400 (EDT)
Date: Mon, 20 Jun 2011 10:53:21 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 01/12] vmscan: add shrink_slab tracepoints
Message-ID: <20110620005321.GM561@dastard>
References: <1306998067-27659-1-git-send-email-david@fromorbit.com>
 <1306998067-27659-2-git-send-email-david@fromorbit.com>
 <4DFE97F1.2030206@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4DFE97F1.2030206@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

On Mon, Jun 20, 2011 at 09:44:33AM +0900, KOSAKI Motohiro wrote:
> (2011/06/02 16:00), Dave Chinner wrote:
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > D?t is impossible to understand what the shrinkers are actually doing
> > without instrumenting the code, so add a some tracepoints to allow
> > insight to be gained.
> > 
> > Signed-off-by: Dave Chinner <dchinner@redhat.com>
> > ---
> >  include/trace/events/vmscan.h |   67 +++++++++++++++++++++++++++++++++++++++++
> >  mm/vmscan.c                   |    6 +++-
> >  2 files changed, 72 insertions(+), 1 deletions(-)
> 
> This look good to me. I have two minor request. 1) please change patch order,
> move this patch after shrinker changes. iow, now both this and [2/12] have
> tracepoint change. I don't like it.

No big deal - I'll just fold the second change (how shrinker->nr is
passed into the tracepoint) into the first. Tracepoints should be
first in the series, anyway, otherwise there is no way to validate
the before/after effect of the bug fixes....

> 2) please avoid cryptic abbreviated variable
> names. Instead, please just use the same variable name with
> vmscan.c source code.

So replace cryptic abbreviated names with slightly different
cryptic abbreviated names? ;)

Sure, I can do that...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
