Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 979578D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 20:34:30 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id CB81C3EE0BC
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 09:34:26 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AFAB745DE60
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 09:34:26 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9249745DE5A
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 09:34:26 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 83C531DB804D
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 09:34:26 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4AE801DB8046
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 09:34:26 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to expand_upwards
In-Reply-To: <alpine.DEB.2.00.1104211230030.5829@chino.kir.corp.google.com>
References: <20110421221712.9184.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1104211230030.5829@chino.kir.corp.google.com>
Message-Id: <20110422093406.FA56.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 22 Apr 2011 09:34:25 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, James Bottomley <James.Bottomley@hansenpartnership.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>

> On Thu, 21 Apr 2011, KOSAKI Motohiro wrote:
> 
> > ia64 and mips have CONFIG_ARCH_POPULATES_NODE_MAP and it initialize
> > N_NORMAL_MEMORY automatically if my understand is correct.
> > (plz see free_area_init_nodes)
> > 
> 
> ia64 doesn't enable CONFIG_HIGHMEM, so it never gets set via this generic 
> code; mips also doesn't enable it for all configs even for 32-bit.
> 
> So we'll either want to take check_for_regular_memory() out from under 
> CONFIG_HIGHMEM and do it for all configs or teach slub to use 
> N_HIGH_MEMORY rather than N_NORMAL_MEMORY.

Hey, I already told this thing.

If CONFIG_HIGHMEM=n, N_HIGH_MEMORY and N_NORMAL_MEMORY are share the
same value. then, 
	node_set_state(nid, N_HIGH_MEMORY) in free_area_init_nodes()

mean set both N_HIGH_MEMORY and N_NORMAL_MEMORY.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
