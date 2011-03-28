Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0E1ED8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 08:21:43 -0400 (EDT)
Received: by iyf13 with SMTP id 13so5001141iyf.14
        for <linux-mm@kvack.org>; Mon, 28 Mar 2011 05:21:40 -0700 (PDT)
Date: Mon, 28 Mar 2011 21:21:25 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 2/5] Revert "oom: give the dying task a higher priority"
Message-ID: <20110328122125.GA1892@barrios-desktop>
References: <20110315153801.3526.A69D9226@jp.fujitsu.com>
 <20110322194721.B05E.A69D9226@jp.fujitsu.com>
 <20110322200657.B064.A69D9226@jp.fujitsu.com>
 <20110324152757.GC1938@barrios-desktop>
 <1301305896.4859.8.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1301305896.4859.8.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>

Hi Peter,

On Mon, Mar 28, 2011 at 11:51:36AM +0200, Peter Zijlstra wrote:
> On Fri, 2011-03-25 at 00:27 +0900, Minchan Kim wrote:
> > 
> > At that time, I thought that routine is meaningless in non-RT scheduler.
> > So I Cced Peter but don't get the answer.
> > I just want to confirm it. 
> 
> Probably lost somewhere in the mess that is my inbox :/, what is the
> full question?

The question is we had a routine which change rt.time_slice with HZ to 
accelarate task exit. But when we applied 93b43fa5508, we found it isn't effective
any more about normal task. So we removed it. Is it right?

And Kosaki is about to revert 93b43fa5508 to find out the problem of this thread
and Luis said he has a another solution to replace 93b43fa5508. 
If rt.time_slice handleing is effective, we should restore it until Luis's patch
will be merged.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
