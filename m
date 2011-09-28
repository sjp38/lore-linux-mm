Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C5B569000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 04:04:28 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 45A173EE0C1
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 17:04:25 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 27FDE45DF56
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 17:04:25 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 015C045DF48
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 17:04:25 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DF0531DB8037
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 17:04:24 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A74C51DB802F
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 17:04:24 +0900 (JST)
Date: Wed, 28 Sep 2011 17:03:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/9] kstaled: skip non-RAM regions.
Message-Id: <20110928170334.a56e1695.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1317170947-17074-6-git-send-email-walken@google.com>
References: <1317170947-17074-1-git-send-email-walken@google.com>
	<1317170947-17074-6-git-send-email-walken@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Balbir Singh <bsingharora@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Michael Wolf <mjwolf@us.ibm.com>

On Tue, 27 Sep 2011 17:49:03 -0700
Michel Lespinasse <walken@google.com> wrote:

> Add a pfn_skip_hole function that shrinks the passed input range in order to
> skip over pfn ranges that are known not bo be RAM backed. The x86
> implementation achieves this using e820 tables; other architectures
> use a generic no-op implementation.
> 
> 
> Signed-off-by: Michel Lespinasse <walken@google.com>

Hm, can't you use walk_system_ram_range() in kernel/resource.c ?
If it's enough, please update it.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
