Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id F2BA66B01EF
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 16:30:26 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id o2UKUM1U008781
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 22:30:22 +0200
Received: from pzk1 (pzk1.prod.google.com [10.243.19.129])
	by kpbe19.cbf.corp.google.com with ESMTP id o2UKT1h7018973
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 13:30:21 -0700
Received: by pzk1 with SMTP id 1so217681pzk.23
        for <linux-mm@kvack.org>; Tue, 30 Mar 2010 13:30:20 -0700 (PDT)
Date: Tue, 30 Mar 2010 13:30:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -mm] proc: don't take ->siglock for /proc/pid/oom_adj
In-Reply-To: <20100330174337.GA21663@redhat.com>
Message-ID: <alpine.DEB.2.00.1003301329420.5234@chino.kir.corp.google.com>
References: <1269447905-5939-1-git-send-email-anfei.zhou@gmail.com> <20100326150805.f5853d1c.akpm@linux-foundation.org> <20100326223356.GA20833@redhat.com> <20100328145528.GA14622@desktop> <20100328162821.GA16765@redhat.com>
 <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329112111.GA16971@redhat.com> <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330163909.GA16884@redhat.com> <20100330174337.GA21663@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Mar 2010, Oleg Nesterov wrote:

> ->siglock is no longer needed to access task->signal, change
> oom_adjust_read() and oom_adjust_write() to read/write oom_adj
> lockless.
> 
> Yes, this means that "echo 2 >oom_adj" and "echo 1 >oom_adj"
> can race and the second write can win, but I hope this is OK.
> 

Ok, but could you base this on -mm at 
http://userweb.kernel.org/~akpm/mmotm/ since an additional tunable has 
been added (oom_score_adj), which does the same thing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
