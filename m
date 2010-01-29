Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7B4826B0082
	for <linux-mm@kvack.org>; Fri, 29 Jan 2010 11:25:47 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0TGPirs007103
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 30 Jan 2010 01:25:45 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id BB1B645DE4F
	for <linux-mm@kvack.org>; Sat, 30 Jan 2010 01:25:44 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8AD2545DE53
	for <linux-mm@kvack.org>; Sat, 30 Jan 2010 01:25:44 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 69131E18002
	for <linux-mm@kvack.org>; Sat, 30 Jan 2010 01:25:44 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B78361DB8040
	for <linux-mm@kvack.org>; Sat, 30 Jan 2010 01:25:43 +0900 (JST)
Message-ID: <c6c48fdf7f746add49bb9cc058b513ae.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20100129162137.79b2a6d4@lxorguk.ukuu.org.uk>
References: 
    <f8c9aca9c98db8ae7df3ac2d7ac8d922.squirrel@webmail-b.css.fujitsu.com>
    <20100129162137.79b2a6d4@lxorguk.ukuu.org.uk>
Date: Sat, 30 Jan 2010 01:25:43 +0900 (JST)
Subject: Re: [PATCH v3] oom-kill: add lowmem usage aware oom kill handling
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, vedran.furac@gmail.com, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, rientjes@google.com, minchan.kim@gmail.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Alan Cox wrote:
>> panic_on_oom=1 works enough well.For Vedran's, overcommit memory will
>> work
>> well. But oom-killer kills very bad process if not tweaked.
>> So, I think some improvement should be done.
>
> That is why we have the per process oom_adj values - because for nearly
> fifteen years someone comes along and says "actually in my environment
> the right choice is ..."
>
> Ultimately it is policy. The kernel simply can't read minds.
>
If so, all heuristics other than vm_size should be purged, I think.
...Or victim should be just determined by the class of application
user sets. oom_adj other than OOM_DISABLE, searching victim process
by black magic are all garbage.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
