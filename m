Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id BA26F6B004D
	for <linux-mm@kvack.org>; Sun, 19 Feb 2012 21:50:52 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 6AEA73EE0BC
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 11:50:50 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B9BA45DE4E
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 11:50:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D5F445DD74
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 11:50:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 058071DB803C
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 11:50:50 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AE24B1DB802C
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 11:50:49 +0900 (JST)
Date: Mon, 20 Feb 2012 11:49:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] rmap: anon_vma_prepare: Reduce code duplication by
 calling anon_vma_chain_link
Message-Id: <20120220114928.8507095c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1329488908-7304-1-git-send-email-consul.kautuk@gmail.com>
References: <1329488908-7304-1-git-send-email-consul.kautuk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kautuk Consul <consul.kautuk@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 17 Feb 2012 09:28:28 -0500
Kautuk Consul <consul.kautuk@gmail.com> wrote:

> Reduce code duplication by calling anon_vma_chain_link from
> anon_vma_prepare.
> 
> Also move the anon_vmal_chain_link function to a more suitable location
> in the file.
> 
> Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>

Reviewed-by: KAMEZWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
