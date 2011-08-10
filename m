Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 47FF0900146
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 20:06:12 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E3C0F3EE0AE
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 09:06:08 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C899B45DF47
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 09:06:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B251945DE7C
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 09:06:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A4A26E18002
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 09:06:08 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C8931DB803F
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 09:06:08 +0900 (JST)
Date: Thu, 11 Aug 2011 08:58:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2][cleanup] memcg: renaming of mem variable to memcg
Message-Id: <20110811085842.c689749a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110810172929.23280.76419.sendpatchset@oc5400248562.ibm.com>
References: <20110810172917.23280.9440.sendpatchset@oc5400248562.ibm.com>
	<20110810172929.23280.76419.sendpatchset@oc5400248562.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Cc: Arend van Spriel <arend@broadcom.com>, Greg Kroah-Hartman <gregkh@suse.de>, "David S. Miller" <davem@davemloft.net>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, "John W. Linville" <linville@tuxdriver.com>, Mauro Carvalho Chehab <mchehab@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>

On Wed, 10 Aug 2011 22:59:29 +0530
Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com> wrote:

>  The memcg code sometimes uses "struct mem_cgroup *mem" and sometimes uses
>  "struct mem_cgroup *memcg". This patch renames all mem variables to memcg in
>  source file.
> 
> From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
> Signed-off-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>

Basically...

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

My concern is that this may HUNK with patches planend to be post..
but it seems rework will be small.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
