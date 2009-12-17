Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4DC536B0044
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 17:23:45 -0500 (EST)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id nBHMNhiw007243
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 14:23:43 -0800
Received: from pwi20 (pwi20.prod.google.com [10.241.219.20])
	by kpbe19.cbf.corp.google.com with ESMTP id nBHMNeul030893
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 14:23:41 -0800
Received: by pwi20 with SMTP id 20so1626191pwi.9
        for <linux-mm@kvack.org>; Thu, 17 Dec 2009 14:23:40 -0800 (PST)
Date: Thu, 17 Dec 2009 14:23:39 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [BUGFIX][PATCH] oom-kill: fix NUMA consraint check with nodemask
 v4.2
In-Reply-To: <20091215140913.e28f7674.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0912171422290.4089@chino.kir.corp.google.com>
References: <20091110162121.361B.A69D9226@jp.fujitsu.com> <20091111134514.4edd3011.kamezawa.hiroyu@jp.fujitsu.com> <20091111142811.eb16f062.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0911102155580.2924@chino.kir.corp.google.com>
 <20091111152004.3d585cee.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0911102224440.6652@chino.kir.corp.google.com> <20091111153414.3c263842.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0911171609370.12532@chino.kir.corp.google.com>
 <20091118095824.076c211f.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0911171725050.13760@chino.kir.corp.google.com> <20091214171632.0b34d833.akpm@linux-foundation.org> <20091215103202.eacfd64e.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.0912142025090.29243@chino.kir.corp.google.com> <20091215134327.6c46b586.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0912142054520.436@chino.kir.corp.google.com> <20091215140913.e28f7674.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 15 Dec 2009, KAMEZAWA Hiroyuki wrote:

> What I can't undestand is the technique to know whether a (unknown) process is
> leaking memory or not by checking vm_size.

Memory leaks are better identified via total_vm since leaked memory has a 
lower probability of staying resident in physical memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
