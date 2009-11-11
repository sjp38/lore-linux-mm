Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id F3A496B0087
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 22:13:09 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAB3D7Ki011508
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 11 Nov 2009 12:13:07 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1374645DE4F
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 12:13:07 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id DCEE945DE54
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 12:13:06 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C3585E1800E
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 12:13:06 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 64E4D1DB803C
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 12:13:06 +0900 (JST)
Date: Wed, 11 Nov 2009 12:10:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] oom-kill: fix NUMA consraint check with
 nodemask v3
Message-Id: <20091111121028.b4a0ffe7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091111115217.FD56.A69D9226@jp.fujitsu.com>
References: <20091111112404.0026e601.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0911101841480.11083@chino.kir.corp.google.com>
	<20091111115217.FD56.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 11 Nov 2009 12:02:06 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > There should be a way around that, however.  Shouldn't
> > 
> > 	if (nodes_subset(node_states[N_HIGH_MEMORY], *nodemask))
> > 		return CONSTRAINT_MEMORY_POLICY;
> > 
> > be sufficient?
> 
> Is this safe on memory hotplug case?
> 
N_HIGH_MEMORY is updated at memory hotplug.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
