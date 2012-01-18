Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 989F56B004D
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 07:30:43 -0500 (EST)
Received: by wgbdr13 with SMTP id dr13so2200257wgb.26
        for <linux-mm@kvack.org>; Wed, 18 Jan 2012 04:30:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120117140712.GC14907@tiehlicka.suse.cz>
References: <CAJd=RBBdDriMhfetM2AWGzgxiJ1DDs-W4Ff9_1Z8DUgbyQmSkA@mail.gmail.com>
	<20120117131601.GB14907@tiehlicka.suse.cz>
	<CAJd=RBBcL5RuW1wC_Yh=gy2Ja8wqJ6jhf28zNi1n6MJ=+0=m2Q@mail.gmail.com>
	<20120117140712.GC14907@tiehlicka.suse.cz>
Date: Wed, 18 Jan 2012 20:30:41 +0800
Message-ID: <CAJd=RBAyqPwKERQL4JyCO38gjE=y8_qasHTbLtMGWqtZ1JFnUg@mail.gmail.com>
Subject: Re: [PATCH] mm: memcg: remove checking reclaim order in soft limit reclaim
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jan 17, 2012 at 10:07 PM, Michal Hocko <mhocko@suse.cz> wrote:
> On Tue 17-01-12 21:29:52, Hillf Danton wrote:
>> On Tue, Jan 17, 2012 at 9:16 PM, Michal Hocko <mhocko@suse.cz> wrote:
>> > Hi,
>> >
>> > On Tue 17-01-12 20:47:59, Hillf Danton wrote:
>> >> If async order-O reclaim expected here, it is settled down when setting up scan
>> >> control, with scan priority hacked to be zero. Other than that, deny of reclaim
>> >> should be removed.
>> >
>> > Maybe I have misunderstood you but this is not right. The check is to
>> > protect from the _global_ reclaim with order > 0 when we prevent from
>> > memcg soft reclaim.
>> >
>> need to bear mm hog in this way?
>
> Could you be more specific? Are you trying to fix any particular
> problem?
>
My thought is simple, the outcome of softlimit reclaim depends little on the
value of reclaim order, zero or not, and only exceeding is reclaimed, so
selective response to swapd's request is incorrect.

> Global reclaim should take are of the global memory pressure. Soft
> reclaim is intended just to make its job easier. Btw. softlimit reclaim
> is on its way out of the kernel but this will not happen in 3.3.
>
I will check it in 3.3 if too late for 3.2.

Thanks
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
