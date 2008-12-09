Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB93xP9W001706
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 9 Dec 2008 12:59:26 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id AD17D45DD78
	for <linux-mm@kvack.org>; Tue,  9 Dec 2008 12:59:25 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8BBB645DD7F
	for <linux-mm@kvack.org>; Tue,  9 Dec 2008 12:59:25 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 50ADA1DB803B
	for <linux-mm@kvack.org>; Tue,  9 Dec 2008 12:59:25 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 08DCCE08001
	for <linux-mm@kvack.org>; Tue,  9 Dec 2008 12:59:22 +0900 (JST)
Date: Tue, 9 Dec 2008 12:58:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [mm] [PATCH 3/4] Memory cgroup hierarchical reclaim (v4)
Message-Id: <20081209125829.556b1e40.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081209125341.456bf635.nishimura@mxp.nes.nec.co.jp>
References: <20081116081034.25166.7586.sendpatchset@balbir-laptop>
	<20081116081055.25166.85066.sendpatchset@balbir-laptop>
	<20081125205832.38f8c365.nishimura@mxp.nes.nec.co.jp>
	<492C1345.9090201@linux.vnet.ibm.com>
	<20081126111447.106ec275.nishimura@mxp.nes.nec.co.jp>
	<20081209115943.7d6a0ea3.kamezawa.hiroyu@jp.fujitsu.com>
	<20081209125341.456bf635.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 9 Dec 2008 12:53:41 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> Not yet.
> 
> Those dead locks cannot be fixed as long as reclaim path tries to hold cgroup_mutex.
> (current mmotm doesn't hold cgroup_mutex on reclaim path if !use_hierarchy and
> I'm testing with !use_hierarchy. It works well basically, but I got another bug
> at rmdir today, and digging it now.)
> 
> The dead lock I've fixed by memcg-avoid-dead-lock-caused-by-race-between-oom-and-cpuset_attach.patch
> is another one(removed cgroup_lock from oom code).
> 
Okay, then removing cgroup_lock from memory-reclaim path is a way to go..

Thank you.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
