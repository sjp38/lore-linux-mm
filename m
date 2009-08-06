Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 70CAA6B005A
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 01:13:13 -0400 (EDT)
Received: by ywh14 with SMTP id 14so847594ywh.1
        for <linux-mm@kvack.org>; Wed, 05 Aug 2009 22:13:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090805163945.056c463c.akpm@linux-foundation.org>
References: <20090804191031.6A3D.A69D9226@jp.fujitsu.com>
	 <20090805163945.056c463c.akpm@linux-foundation.org>
Date: Thu, 6 Aug 2009 14:13:16 +0900
Message-ID: <2f11576a0908052213m3fba4154ifb73ab1ae2ea74d6@mail.gmail.com>
Subject: Re: [PATCH for 2.6.31 0/4] fix oom_adj regression v2
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> So I merged these but I have a feeling that this isn't the last I'll be
> hearing on the topic ;)
>
> Given the amount of churn, the amount of discussion and the size of the
> patches, this doesn't look like something we should push into 2.6.31.
>
> If we think that the 2ff05b2b regression is sufficiently serious to be
> a must-fix for 2.6.31 then can we please find something safer and
> smaller? =A0Like reverting 2ff05b2b?

I don't think the serious problem is only  this issue, I oppose to
ignore regression
bug report ;-)

Yes, your point makes sense. then, I'll make two patch series.
1. reverting 2ff05b2b for 2.6.31
2. retry fix oom livelock for -mm

I expect I can do that next sunday.


> These patches clash with the controversial
> mm-introduce-proc-pid-oom_adj_child.patch, so I've disabled that patch
> now.

I think we can drop this because workaround patch is only needed until
the issue not fixed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
