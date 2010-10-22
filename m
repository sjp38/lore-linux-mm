Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1A8846B004A
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 00:39:42 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9M4ddV5012701
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 22 Oct 2010 13:39:39 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E86D45DE57
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 13:39:39 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E71C345DE51
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 13:39:38 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A0DEE18008
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 13:39:38 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E1F5E18002
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 13:39:38 +0900 (JST)
Date: Fri, 22 Oct 2010 13:34:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V3] nommu: add anonymous page memcg accounting
Message-Id: <20101022133413.3ab2df01.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101022035302.GA15844@balbir.in.ibm.com>
References: <1287664088-4483-1-git-send-email-steve@digidescorp.com>
	<20101022035302.GA15844@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "Steven J. Magnani" <steve@digidescorp.com>, linux-mm@kvack.org, dhowells@redhat.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 22 Oct 2010 09:23:03 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * Steven J. Magnani <steve@digidescorp.com> [2010-10-21 07:28:08]:
> 
> > Add the necessary calls to track VM anonymous page usage (only).
> > 
> > V3 changes:
> > * Use vma->vm_mm instead of current->mm when charging pages, for clarity
> > * Document that reclaim is not possible with only anonymous page accounting
> >   so the OOM-killer is invoked when a limit is exceeded
> > * Add TODO to implement file cache (reclaim) support or optimize away
> >   page_cgroup->lru
> > 
> > V2 changes:
> > * Added update of memory cgroup documentation
> > * Clarify use of 'file' to distinguish anonymous mappings
> > 
> > Signed-off-by: Steven J. Magnani <steve@digidescorp.com>
> 
> Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> BTW, I have no way of testing this, we need to rely on the NOMMU
> community to test this.
>  
Yes, that's the biggest problem.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
