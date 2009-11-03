Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3EA4E6B0044
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 18:09:13 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA3N9Apu003614
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 4 Nov 2009 08:09:10 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1105845DE55
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 08:09:10 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D1DC945DE4E
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 08:09:09 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id ACBEBE1800A
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 08:09:09 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5DC1AE1800F
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 08:09:09 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] oom_kill: use rss value instead of vm size for badness
In-Reply-To: <4AEF394A.4050102@gmail.com>
References: <2f11576a0911020435n103538d0p9d2afed4d39b4726@mail.gmail.com> <4AEF394A.4050102@gmail.com>
Message-Id: <20091104002903.0B4D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Wed,  4 Nov 2009 08:09:08 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: vedran.furac@gmail.com
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

> KOSAKI Motohiro wrote:
> 
> > Oh, I'm sorry. I mesured with rss patch.
> > Then, I haven't understand what makes Xorg bad score.
> > 
> > Hmm...
> > Vedran,  Can you please post following command result?
> > 
> > # cat /proc/`pidof Xorg`/smaps
> > 
> > I hope to undestand the issue clearly before modify any code.
> 
> No problem:
> 
> http://pastebin.com/d66972025 (long)
> 
> Xorg is from debian unstable.

Hmm...

Your Xorg have pretty large heap. I'm not sure why it happen.
(ATI video card issue?)
Unfortunatelly, It is showed as normal large heap from kernel. then,
I doubt kernel can distinguish X from other process. Probably
oom-adj is most reasonable option....

-------------------------------------------------
[heap]
Size:             433812 kB
Rss:              433304 kB
Pss:              433304 kB
Shared_Clean:          0 kB
Shared_Dirty:          0 kB
Private_Clean:       280 kB
Private_Dirty:    433024 kB
Referenced:       415656 kB
Swap:                  0 kB
KernelPageSize:        4 kB
MMUPageSize:           4 kB




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
