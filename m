Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7062B8D0039
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 15:54:55 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id p2FJspWJ011081
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 12:54:52 -0700
Received: from pwj9 (pwj9.prod.google.com [10.241.219.73])
	by kpbe17.cbf.corp.google.com with ESMTP id p2FJskXC015951
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 12:54:50 -0700
Received: by pwj9 with SMTP id 9so156176pwj.6
        for <linux-mm@kvack.org>; Tue, 15 Mar 2011 12:54:50 -0700 (PDT)
Date: Tue, 15 Mar 2011 12:54:47 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3 for 2.6.38] oom: oom_kill_process: don't set TIF_MEMDIE
 if !p->mm
In-Reply-To: <20110315185316.GA21640@redhat.com>
Message-ID: <alpine.DEB.2.00.1103151252000.558@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1103081549530.27910@chino.kir.corp.google.com> <20110309151946.dea51cde.akpm@linux-foundation.org> <alpine.DEB.2.00.1103111142260.30699@chino.kir.corp.google.com> <20110312123413.GA18351@redhat.com> <20110312134341.GA27275@redhat.com>
 <AANLkTinHGSb2_jfkwx=Wjv96phzPCjBROfCTFCKi4Wey@mail.gmail.com> <20110313212726.GA24530@redhat.com> <20110314190419.GA21845@redhat.com> <20110314190446.GB21845@redhat.com> <alpine.DEB.2.00.1103141314190.31514@chino.kir.corp.google.com>
 <20110315185316.GA21640@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrey Vagin <avagin@openvz.org>, Frantisek Hrbata <fhrbata@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 15 Mar 2011, Oleg Nesterov wrote:

> Confused. I sent the test-case. OK, may be you meant the code in -mm,
> but I meant the current code.
> 

This entire discussion, and your involvement in it, originated from these 
two patches being merged into -mm:

	oom-prevent-unnecessary-oom-kills-or-kernel-panics.patch
	oom-skip-zombies-when-iterating-tasklist.patch

So naturally I'm going to challenge your testcases with the latest -mm.  
If you wanted to suggest pushing these to 2.6.38 earlier, I don't think 
anyone would have disputed that -- I certainly wouldn't have since the 
first fixes a quite obvious panic that we've faced on a lot of our 
machines.  It's not that big of a deal, though, since Andrew has targeted 
them for -stable and they're on schedule to be pushed to 2.6.38.x

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
