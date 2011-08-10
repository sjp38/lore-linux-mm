Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id AFD74900146
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 20:06:58 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id C81D33EE0C1
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 09:06:55 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id ABE1D45DF53
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 09:06:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 905AE45DF52
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 09:06:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 625E9E18005
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 09:06:55 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 121241DB8040
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 09:06:55 +0900 (JST)
Date: Thu, 11 Aug 2011 08:59:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2][cleanup] memcg: renaming of mem variable to memcg
Message-Id: <20110811085929.bd9919ef.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110810172942.23280.99644.sendpatchset@oc5400248562.ibm.com>
References: <20110810172917.23280.9440.sendpatchset@oc5400248562.ibm.com>
	<20110810172942.23280.99644.sendpatchset@oc5400248562.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Cc: Arend van Spriel <arend@broadcom.com>, Greg Kroah-Hartman <gregkh@suse.de>, "David S. Miller" <davem@davemloft.net>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, "John W. Linville" <linville@tuxdriver.com>, Mauro Carvalho Chehab <mchehab@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>

On Wed, 10 Aug 2011 22:59:42 +0530
Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com> wrote:

>  The memcg code sometimes uses "struct mem_cgroup *mem" and sometimes uses
>  "struct mem_cgroup *memcg". This patch renames all mem variables to memcg in header file.
> 
> From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
> Signed-off-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
