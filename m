Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id DAEB96B0012
	for <linux-mm@kvack.org>; Tue, 31 May 2011 00:48:36 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p4V4mYAE027911
	for <linux-mm@kvack.org>; Mon, 30 May 2011 21:48:34 -0700
Received: from pvh21 (pvh21.prod.google.com [10.241.210.213])
	by hpaq14.eem.corp.google.com with ESMTP id p4V4lUS1002972
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 30 May 2011 21:48:33 -0700
Received: by pvh21 with SMTP id 21so3666128pvh.1
        for <linux-mm@kvack.org>; Mon, 30 May 2011 21:48:32 -0700 (PDT)
Date: Mon, 30 May 2011 21:48:30 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/5] oom: don't kill random process
In-Reply-To: <4DE2F028.6020608@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1105302147250.18793@chino.kir.corp.google.com>
References: <4DD61F80.1020505@jp.fujitsu.com> <4DD6207E.1070300@jp.fujitsu.com> <alpine.DEB.2.00.1105231529340.17840@chino.kir.corp.google.com> <4DDB0B45.2080507@jp.fujitsu.com> <alpine.DEB.2.00.1105231838420.17729@chino.kir.corp.google.com>
 <4DDB1028.7000600@jp.fujitsu.com> <alpine.DEB.2.00.1105231856210.18353@chino.kir.corp.google.com> <4DDB11F4.2070903@jp.fujitsu.com> <alpine.DEB.2.00.1105251645270.29729@chino.kir.corp.google.com> <4DE2F028.6020608@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, oleg@redhat.com

On Mon, 30 May 2011, KOSAKI Motohiro wrote:

> Never mind.
> 
> You never see to increase tasklist_lock. You never seen all processes
> have root privilege case.
> 

I don't really understand what you're trying to say, sorry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
