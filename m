Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C4B546B01D2
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 00:20:49 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id o5H4Kk2Y017642
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 21:20:46 -0700
Received: from pxi14 (pxi14.prod.google.com [10.243.27.14])
	by hpaq11.eem.corp.google.com with ESMTP id o5H4KhtF024766
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 21:20:44 -0700
Received: by pxi14 with SMTP id 14so1740814pxi.0
        for <linux-mm@kvack.org>; Wed, 16 Jun 2010 21:20:43 -0700 (PDT)
Date: Wed, 16 Jun 2010 21:20:41 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 5/9] oom: cleanup has_intersects_mems_allowed()
In-Reply-To: <20100617104719.FB8C.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006162119540.14101@chino.kir.corp.google.com>
References: <20100617104311.FB7A.A69D9226@jp.fujitsu.com> <20100617104719.FB8C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 17 Jun 2010, KOSAKI Motohiro wrote:

> 
> Now has_intersects_mems_allowed() has own thread iterate logic, but
> it should use while_each_thread().
> 
> It slightly improve the code readability.
> 
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

I disagree that the renaming of the variables is necessary, please simply 
change the while (tsk != start) to use while_each_thread(tsk, start);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
