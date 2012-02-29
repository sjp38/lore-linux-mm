Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 75A4F6B004A
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 19:38:42 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 08EF23EE0AE
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 09:38:41 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DFE6645DE53
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 09:38:40 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C7C9445DE51
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 09:38:40 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B12DB1DB8042
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 09:38:40 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6CE0C1DB8040
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 09:38:40 +0900 (JST)
Date: Wed, 29 Feb 2012 09:37:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH resend] mm: drain percpu lru add/rotate page-vectors on
 cpu hot-unplug
Message-Id: <20120229093713.e017c7f9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120228193620.32063.83425.stgit@zurg>
References: <20120228193620.32063.83425.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Tue, 28 Feb 2012 23:40:45 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> This cpu hotplug hook was accidentally removed in commit v2.6.30-rc4-18-g00a62ce
> ("mm: fix Committed_AS underflow on large NR_CPUS environment")
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
