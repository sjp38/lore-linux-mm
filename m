Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B41666B01F4
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 08:08:11 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o36C87eS013458
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 6 Apr 2010 21:08:07 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4DDEB45DE4D
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 21:08:07 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0AC3345DE4E
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 21:08:07 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D2C0D1DB803E
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 21:08:06 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 68647E08001
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 21:08:06 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm] memcg: make oom killer a no-op when no killable task can be found
In-Reply-To: <alpine.DEB.2.00.1004051552400.27040@chino.kir.corp.google.com>
References: <20100405154923.23228529.akpm@linux-foundation.org> <alpine.DEB.2.00.1004051552400.27040@chino.kir.corp.google.com>
Message-Id: <20100406201645.7E69.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  6 Apr 2010 21:08:05 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, anfei <anfei.zhou@gmail.com>, nishimura@mxp.nes.nec.co.jp, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> This is not the first time we have changed or obsoleted tunables in 
> /proc/sys/vm.  If a startup tool really is really bailing out depending on 
> whether echo 1 > /proc/sys/vm/oom_kill_allocating_task succeeds, it should 
> be fixed regardless because you're not protecting anything by doing that 
>
> since you can't predict what task is allocating memory at the time of oom.  
> Those same startup tools will need to disable /proc/sys/vm/oom_dump_tasks 
> if we are to remove the consolidation into oom_kill_quick and maintain two 
> seperate VM sysctls that are always used together by the same users.
>
> Nobody can even cite a single example of oom_kill_allocating_task being 
> used in practice, yet we want to unnecessarily maintain these two seperate 
> sysctls forever because it's possible that a buggy startup tool cares 
> about the return value of enabling it?
> 
> > Others had other objections, iirc.
> > 
> 
> I'm all ears.

Complain.

Many people reviewed these patches, but following four patches got no ack.

oom-badness-heuristic-rewrite.patch
oom-default-to-killing-current-for-pagefault-ooms.patch
oom-deprecate-oom_adj-tunable.patch
oom-replace-sysctls-with-quick-mode.patch

IIRC, alan and nick and I NAKed such patch. everybody explained the reason.
We don't hope join loudly voice contest nor help to making flame. but it
doesn't mean explicit ack.

Andrew, If you really really really hope to merge these, I'm not againt
it anymore. but please put following remark explicitely into the patches.

	Nacked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujistu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
