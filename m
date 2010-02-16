Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 184706B0082
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 04:04:51 -0500 (EST)
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id o1G94nFu021528
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 01:04:49 -0800
Received: from pzk15 (pzk15.prod.google.com [10.243.19.143])
	by kpbe18.cbf.corp.google.com with ESMTP id o1G94l9W029343
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 01:04:48 -0800
Received: by pzk15 with SMTP id 15so5650116pzk.11
        for <linux-mm@kvack.org>; Tue, 16 Feb 2010 01:04:47 -0800 (PST)
Date: Tue, 16 Feb 2010 01:04:44 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 5/7 -mm] oom: replace sysctls with quick mode
In-Reply-To: <20100216141539.72EF.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002160102480.17122@chino.kir.corp.google.com>
References: <20100215170634.729E.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1002151411530.26927@chino.kir.corp.google.com> <20100216141539.72EF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Feb 2010, KOSAKI Motohiro wrote:

> > > "_quick" is always bad sysctl name.
> > 
> > Why?  It does exactly what it says: it kills current without doing an 
> > expensive tasklist scan and suppresses the possibly long tasklist dump.  
> > That's the oom killer's "quick mode."
> 
> Because, an administrator think "_quick" implies "please use it always".
> plus, "quick" doesn't describe clealy meanings. oom_dump_tasks does.
> 

The audience for both of these tunables (now that oom_dump_tasks is 
default to enabled) is users with extremely long tasklists that want to 
avoid those scans, so oom_kill_quick implies that it won't waste any time 
and will act how it's documented: simply kill current and move on.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
