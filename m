Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 107D06B0011
	for <linux-mm@kvack.org>; Wed,  4 May 2011 04:58:53 -0400 (EDT)
Date: Wed, 4 May 2011 10:58:51 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/7] memcg: add high/low watermark to res_counter
Message-ID: <20110504085851.GC1375@tiehlicka.suse.cz>
References: <20110425182849.ab708f12.kamezawa.hiroyu@jp.fujitsu.com>
 <20110429133313.GB306@tiehlicka.suse.cz>
 <20110501150410.75D2.A69D9226@jp.fujitsu.com>
 <20110503064945.GA18927@tiehlicka.suse.cz>
 <BANLkTimmpHcSJuO_8+P=GjYf+wB=Nyq=4w@mail.gmail.com>
 <20110503082550.GD18927@tiehlicka.suse.cz>
 <BANLkTikZtOdzsnjH=43AegLCpYc6ecfKsg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTikZtOdzsnjH=43AegLCpYc6ecfKsg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>

On Tue 03-05-11 10:01:27, Ying Han wrote:
> On Tue, May 3, 2011 at 1:25 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Tue 03-05-11 16:45:23, KOSAKI Motohiro wrote:
> >> 2011/5/3 Michal Hocko <mhocko@suse.cz>:
> >> > On Sun 01-05-11 15:06:02, KOSAKI Motohiro wrote:
> >> >> > On Mon 25-04-11 18:28:49, KAMEZAWA Hiroyuki wrote:
[...]
> >> >> Can you please clarify this? I feel it is not opposite semantics.
> >> >
> >> > In the global reclaim low watermark represents the point when we _start_
> >> > background reclaim while high watermark is the _stopper_. Watermarks are
> >> > based on the free memory while this proposal makes it based on the used
> >> > memory.
> >> > I understand that the result is same in the end but it is really
> >> > confusing because you have to switch your mindset from free to used and
> >> > from under the limit to above the limit.
> >>
> >> Ah, right. So, do you have an alternative idea?
> >
> > Why cannot we just keep the global reclaim semantic and make it free
> > memory (hard_limit - usage_in_bytes) based with low limit as the trigger
> > for reclaiming?
> 
[...]
> The current scheme 

What is the current scheme?

> is closer to the global bg reclaim which the low is triggering reclaim
> and high is stopping reclaim. And we can only use the "usage" to keep
> the same API.

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
