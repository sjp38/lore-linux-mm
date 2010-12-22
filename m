Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 05A846B0087
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 03:31:32 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBM8VT36016696
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 22 Dec 2010 17:31:29 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 407A945DE70
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 17:31:29 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 293C645DE6C
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 17:31:29 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 174D11DB803F
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 17:31:29 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D66931DB803B
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 17:31:28 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch] memcg: add oom killer delay
In-Reply-To: <20101222171749.06ef5559.kamezawa.hiroyu@jp.fujitsu.com>
References: <20101221235924.b5c1aecc.akpm@linux-foundation.org> <20101222171749.06ef5559.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20101222173112.C6B5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 22 Dec 2010 17:31:28 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Divyesh Shah <dpshah@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> seems to be hard to use. No one can estimate "milisecond" for avoidling
> OOM-kill. I think this is very bad. Nack to this feature itself.
> 
> 
> If you want something smart _in kernel_, please implement followings.
> 
>  - When hit oom, enlarge limit to some extent.
>  - All processes in cgroup should be stopped.
>  - A helper application will be called by usermode_helper().
>  - When a helper application exit(), automatically release all processes
>    to run again.
> 
> Then, you can avoid oom-kill situation in automatic with kernel's help.

I bet a monitor use diffent memcg is simplest thing.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
