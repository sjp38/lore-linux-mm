Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id ED1168D0040
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 20:04:16 -0400 (EDT)
Received: by iwg8 with SMTP id 8so1513355iwg.14
        for <linux-mm@kvack.org>; Fri, 25 Mar 2011 17:04:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTin51sZ2fsOzfaSWQCWkrQ+JkyVWNnM022E2GFwQ@mail.gmail.com>
References: <20110324182240.5fe56de2.kamezawa.hiroyu@jp.fujitsu.com>
	<20110324105222.GA2625@barrios-desktop>
	<20110325090411.56c5e5b2.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=f3gu7-8uNiT4qz6s=BOhto5s=7g@mail.gmail.com>
	<20110325115453.82a9736d.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTim3fFe3VzvaWRwzaCT6aRd-yeyfiQ@mail.gmail.com>
	<AANLkTin51sZ2fsOzfaSWQCWkrQ+JkyVWNnM022E2GFwQ@mail.gmail.com>
Date: Sat, 26 Mar 2011 09:04:14 +0900
Message-ID: <AANLkTimvu2xEnDvF=HDqDxoOECp=56yj08CMSa=Fsru9@mail.gmail.com>
Subject: Re: [PATCH 0/4] forkbomb killer
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Walters <walters@verbum.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "rientjes@google.com" <rientjes@google.com>, Andrey Vagin <avagin@openvz.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

If you set up cpu+memory cgroup properly, I think it works well.

For well scheduled servers or some production devices, all
applications and relationship
of them can be designed properly and you can find the best cgroup set.

For a some desktop environ like mine, which has 1-4G of memory, I think a user
doesn't want to divide resources (limiting memory) for emergency
because I want to
use full resources of my poor host. Of course, I use memcg when I
handle very big
file or memory by an application when I can think of bad effects of that.

And, with experiences in ML.... I've advised "please use memcg" when I see
emails/questions about OOM....but there are still periodic OOM report to ML ;)
Maybe usual users doesn't pay costs to avoid some emergency by themselves.
(Some good daemon software should do that.)

I feel the kernel itself should have the last resort to quit
hard-to-recover status.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
