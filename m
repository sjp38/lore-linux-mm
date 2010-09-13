Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 07B596B0047
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 18:46:12 -0400 (EDT)
Received: by iwn33 with SMTP id 33so7197783iwn.14
        for <linux-mm@kvack.org>; Mon, 13 Sep 2010 15:46:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100913130149.849935145@intel.com>
References: <20100913123110.372291929@intel.com>
	<20100913130149.849935145@intel.com>
Date: Tue, 14 Sep 2010 07:46:01 +0900
Message-ID: <AANLkTi=JuBKdqbGrukVwfVfgs1gixdRd3t77ZGEUL9wj@mail.gmail.com>
Subject: Re: [PATCH 1/4] writeback: integrated background work
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Wu,

On Mon, Sep 13, 2010 at 9:31 PM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
> Check background work whenever the flusher thread wakes up. =A0The page
> reclaim code may lower the soft dirty limit immediately before sending
> some work to the flusher thread.

I looked over this series. First impression is the approach is good. :)
But let me have a question.
I can't find things about soft dirty limit.
Maybe it's a thing based on your another patch series.
But at least, could you explain it in this series if it is really
related to this series?

>
> This is also the prerequisite of next patch.

I can't understand why is the prerequisite of next patch.
Please specify it.

>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>




--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
