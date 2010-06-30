Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 7A5E3600227
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 10:30:27 -0400 (EDT)
Received: by pwi9 with SMTP id 9so318563pwi.14
        for <linux-mm@kvack.org>; Wed, 30 Jun 2010 07:30:20 -0700 (PDT)
Date: Wed, 30 Jun 2010 23:30:13 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 09/11] oom: remove child->mm check from
 oom_kill_process()
Message-ID: <20100630143013.GG15644@barrios-desktop>
References: <20100630172430.AA42.A69D9226@jp.fujitsu.com>
 <20100630183209.AA62.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100630183209.AA62.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 30, 2010 at 06:32:44PM +0900, KOSAKI Motohiro wrote:
> 
> Current "child->mm == p->mm" mean prevent to select vfork() task.
> But we don't have any reason to don't consider vfork().

I guess "child->mm == p->mm" is for losing the minimal amount of work done
as comment say. But frankly speaking, I don't understand it, either.
Maybe "One shot, two kill" problem?

Andrea. Could you explain it?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
