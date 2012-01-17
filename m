Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 09B2F6B00B6
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 08:29:53 -0500 (EST)
Received: by werl4 with SMTP id l4so1943101wer.14
        for <linux-mm@kvack.org>; Tue, 17 Jan 2012 05:29:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120117131601.GB14907@tiehlicka.suse.cz>
References: <CAJd=RBBdDriMhfetM2AWGzgxiJ1DDs-W4Ff9_1Z8DUgbyQmSkA@mail.gmail.com>
	<20120117131601.GB14907@tiehlicka.suse.cz>
Date: Tue, 17 Jan 2012 21:29:52 +0800
Message-ID: <CAJd=RBBcL5RuW1wC_Yh=gy2Ja8wqJ6jhf28zNi1n6MJ=+0=m2Q@mail.gmail.com>
Subject: Re: [PATCH] mm: memcg: remove checking reclaim order in soft limit reclaim
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jan 17, 2012 at 9:16 PM, Michal Hocko <mhocko@suse.cz> wrote:
> Hi,
>
> On Tue 17-01-12 20:47:59, Hillf Danton wrote:
>> If async order-O reclaim expected here, it is settled down when setting up scan
>> control, with scan priority hacked to be zero. Other than that, deny of reclaim
>> should be removed.
>
> Maybe I have misunderstood you but this is not right. The check is to
> protect from the _global_ reclaim with order > 0 when we prevent from
> memcg soft reclaim.
>
need to bear mm hog in this way?

Thanks
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
