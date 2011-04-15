Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C667B900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 19:03:17 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id p3FN3EU3001087
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 16:03:14 -0700
Received: from pwj3 (pwj3.prod.google.com [10.241.219.67])
	by kpbe19.cbf.corp.google.com with ESMTP id p3FN3CXS025340
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 16:03:12 -0700
Received: by pwj3 with SMTP id 3so1489507pwj.29
        for <linux-mm@kvack.org>; Fri, 15 Apr 2011 16:03:12 -0700 (PDT)
Date: Fri, 15 Apr 2011 16:03:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v3] oom: replace PF_OOM_ORIGIN with toggling
 oom_score_adj
In-Reply-To: <alpine.LSU.2.00.1104151528050.4774@sister.anvils>
Message-ID: <alpine.DEB.2.00.1104151602270.2738@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1104131132240.5563@chino.kir.corp.google.com> <20110414090310.07FF.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1104131740280.16515@chino.kir.corp.google.com> <alpine.DEB.2.00.1104141316450.20747@chino.kir.corp.google.com>
 <alpine.LSU.2.00.1104151528050.4774@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Matt Fleming <matt@console-pimps.org>, linux-mm@kvack.org

On Fri, 15 Apr 2011, Hugh Dickins wrote:

> This makes good sense (now you're using MAX instead of MIN!),
> but may I helatedly ask you to change the name test_set_oom_score_adj()
> to replace_oom_score_adj()?  test_set means a bitflag operation to me.
> 

Does replace_oom_score_adj() imply that it will be returning the old value 
of oom_score_adj like test_set_oom_score_adj() does?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
