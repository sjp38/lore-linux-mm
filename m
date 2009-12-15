Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 149176B0047
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 20:17:24 -0500 (EST)
Date: Mon, 14 Dec 2009 17:16:32 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUGFIX][PATCH] oom-kill: fix NUMA consraint check with
 nodemask v4.2
Message-Id: <20091214171632.0b34d833.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.0911171725050.13760@chino.kir.corp.google.com>
References: <20091110162121.361B.A69D9226@jp.fujitsu.com>
	<20091110162445.c6db7521.kamezawa.hiroyu@jp.fujitsu.com>
	<20091110163419.361E.A69D9226@jp.fujitsu.com>
	<20091110164055.a1b44a4b.kamezawa.hiroyu@jp.fujitsu.com>
	<20091110170338.9f3bb417.nishimura@mxp.nes.nec.co.jp>
	<20091110171704.3800f081.kamezawa.hiroyu@jp.fujitsu.com>
	<20091111112404.0026e601.kamezawa.hiroyu@jp.fujitsu.com>
	<20091111134514.4edd3011.kamezawa.hiroyu@jp.fujitsu.com>
	<20091111142811.eb16f062.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0911102155580.2924@chino.kir.corp.google.com>
	<20091111152004.3d585cee.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0911102224440.6652@chino.kir.corp.google.com>
	<20091111153414.3c263842.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0911171609370.12532@chino.kir.corp.google.com>
	<20091118095824.076c211f.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0911171725050.13760@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


So I have a note-to-self here that these patches:

oom_kill-use-rss-value-instead-of-vm-size-for-badness.patch
oom-kill-show-virtual-size-and-rss-information-of-the-killed-process.patch
oom-kill-fix-numa-consraint-check-with-nodemask-v42.patch

are tentative and it was unclear whether I should merge them.

What do we think?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
