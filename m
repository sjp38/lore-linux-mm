Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B60CC6B01BE
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 02:20:00 -0400 (EDT)
Received: by iwn39 with SMTP id 39so1765548iwn.14
        for <linux-mm@kvack.org>; Wed, 02 Jun 2010 23:20:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100603145036.7250.A69D9226@jp.fujitsu.com>
References: <20100603135106.7247.A69D9226@jp.fujitsu.com>
	<20100603145036.7250.A69D9226@jp.fujitsu.com>
Date: Thu, 3 Jun 2010 15:20:00 +0900
Message-ID: <AANLkTimjtfADsrmTLo5wwBMHN3UDRc5ya0gflB3L63vq@mail.gmail.com>
Subject: Re: [PATCH 03/12] oom: the points calculation of child processes must
	use find_lock_task_mm() too
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 3, 2010 at 2:51 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> child point calclation use find_lock_task_mm() too.

Sorry but I have to hurt you, again.
Although we guess what you want, For future, please, write down
description more clearly.

>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Acked-by: Oleg Nesterov <oleg@redhat.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
