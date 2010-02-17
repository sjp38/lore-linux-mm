Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 333466B0078
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 21:19:52 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1H2Jpuv029100
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 17 Feb 2010 11:19:51 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C6422E68C1
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 11:19:51 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CCBD1EF081
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 11:19:51 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E88E21DB8038
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 11:19:50 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A3B8C1DB803C
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 11:19:47 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 4/9 v2] oom: remove compulsory panic_on_oom mode
In-Reply-To: <alpine.DEB.2.00.1002161756100.15079@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002161648570.31753@chino.kir.corp.google.com> <alpine.DEB.2.00.1002161756100.15079@chino.kir.corp.google.com>
Message-Id: <20100217111659.7324.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 17 Feb 2010 11:19:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> +/*
> + * The pagefault handler calls here because it is out of memory, so kill a
> + * memory-hogging task.  If a populated zone has ZONE_OOM_LOCKED set, a parallel
> + * oom killing is already in progress so do nothing.  If a task is found with
> + * TIF_MEMDIE set, it has been killed so do nothing and allow it to exit.
> + */
> +void pagefault_out_of_memory(void)
> +{
> +	if (!try_set_system_oom())
> +		return;
> +	out_of_memory(NULL, 0, 0, NULL);
> +	clear_system_oom();
> +}

At least, I agree pagefault oom part. it need ZONE_OOM_LOCKED too.
if you make separated patch, I'll ack it. I don't know memcg part is 
correct or not.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
