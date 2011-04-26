Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id EB5209000BD
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 23:14:08 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id AD7D93EE0BB
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 12:14:05 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9436345DE91
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 12:14:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DCC645DE76
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 12:14:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 71AA11DB8038
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 12:14:05 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D3091DB8037
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 12:14:05 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] use oom_killer_disabled in all oom pathes
In-Reply-To: <BANLkTimpidn07YRmm0gNDice3xo-tC8kow@mail.gmail.com>
References: <20110426115902.F374.A69D9226@jp.fujitsu.com> <BANLkTimpidn07YRmm0gNDice3xo-tC8kow@mail.gmail.com>
Message-Id: <20110426121555.F378.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue, 26 Apr 2011 12:14:04 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <hidave.darkstar@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> On Tue, Apr 26, 2011 at 10:57 AM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> oom_killer_disable should be a global switch, also fit for oom paths
> >> other than __alloc_pages_slowpath
> >>
> >> Here add it to mem_cgroup_handle_oom and pagefault_out_of_memory as well.
> >
> > Can you please explain more? Why should? Now oom_killer_disabled is used
> > only hibernation path. so, Why pagefault and memcg allocation will be happen?
> 
> Indeed I'm using it in virtio balloon test, oom killer triggered when
> memory pressure is high.
> 
> literally oom_killer_disabled scope should be global, isn't it?

ok. virtio baloon seems fair usage. if you add new usage of oom_killer_disabled 
into the patch description, I'll ack this one.

thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
