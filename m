Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 488356B0062
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 10:04:45 -0500 (EST)
Received: by pwj10 with SMTP id 10so2346645pwj.6
        for <linux-mm@kvack.org>; Mon, 02 Nov 2009 07:04:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091102162244.9425e49b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091102162244.9425e49b.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 3 Nov 2009 00:04:43 +0900
Message-ID: <28c262360911020704r45d7f4fmd347d270622fe2c5@mail.gmail.com>
Subject: Re: [RFC][-mm][PATCH 0/6] oom-killer: total renewal
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, aarcange@redhat.com, akpm@linux-foundation.org, rientjes@google.com, vedran.furac@gmail.com, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

Hi, Kame.

I looked over the patch series.
It's rather big change of OOM.
I see you and David want to make OOM fresh from scratch.
But, It makes for testers to test harder.

I like your idea of fork-bomb detector.
Don't we use it without big change of as-is OOM heuristic?

Anyway,I need time to dive the code and test it.
Maybe weekend.

Thanks for great effort. :)

On Mon, Nov 2, 2009 at 4:22 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Hi, as discussed in "Memory overcommit" threads, I started rewrite.
>
> This is just for showing "I started" (not just chating or sleeping ;)
>
> All implemtations are not fixed yet. So feel free to do any comments.
> This set is for minimum change set, I think. Some more rich functions
> can be implemented based on this.
>
> All patches are against "mm-of-the-moment snapshot 2009-11-01-10-01"
>
> Patches are organized as
>
> (1) pass oom-killer more information, classification and fix mempolicy case.
> (2) counting swap usage
> (3) counting lowmem usage
> (4) fork bomb detector/killer
> (5) check expansion of total_vm
> (6) rewrite __badness().
>
> passed small tests on x86-64 boxes.
>
> Thanks,
> -Kame
>
>



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
