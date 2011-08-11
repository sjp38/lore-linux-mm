Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 236576B00EE
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 03:53:48 -0400 (EDT)
Date: Thu, 11 Aug 2011 09:53:37 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 0/2][cleanup] memcg: renaming of mem variable to memcg
Message-ID: <20110811075337.GA8023@tiehlicka.suse.cz>
References: <20110810172917.23280.9440.sendpatchset@oc5400248562.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110810172917.23280.9440.sendpatchset@oc5400248562.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Cc: Arend van Spriel <arend@broadcom.com>, Greg Kroah-Hartman <gregkh@suse.de>, "David S. Miller" <davem@davemloft.net>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, "John W. Linville" <linville@tuxdriver.com>, Mauro Carvalho Chehab <mchehab@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>

On Wed 10-08-11 22:59:17, Raghavendra K T wrote:
> Hi,
>  This is the memcg cleanup patch for that was talked little ago to change the  "struct
>  mem_cgroup *mem" variable to  "struct mem_cgroup *memcg".
> 
>  The patch is though trivial, it is huge one.
>  Testing : Compile tested with following configurations.
>  1) CONFIG_CGROUP_MEM_RES_CTLR=y  CONFIG_CGROUP_MEM_RES_CTLR_SWAP=y
>  2) CONFIG_CGROUP_MEM_RES_CTLR=y  CONFIG_CGROUP_MEM_RES_CTLR_SWAP=n
>  3) CONFIG_CGROUP_MEM_RES_CTLR=n  CONFIG_CGROUP_MEM_RES_CTLR_SWAP=n

How exactly have you tested? Compiled and compared before/after binaries
(it shouldn't change, right)?

> 
>  Also tested basic mounting with memcgroup.
>  Raghu.

Thanks
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
