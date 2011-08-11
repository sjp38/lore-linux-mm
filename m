Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E3D4D6B016F
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 04:04:55 -0400 (EDT)
Date: Thu, 11 Aug 2011 10:04:47 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2][cleanup] memcg: renaming of mem variable to memcg
Message-ID: <20110811080447.GB8023@tiehlicka.suse.cz>
References: <20110810172917.23280.9440.sendpatchset@oc5400248562.ibm.com>
 <20110810172929.23280.76419.sendpatchset@oc5400248562.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110810172929.23280.76419.sendpatchset@oc5400248562.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Cc: Arend van Spriel <arend@broadcom.com>, Greg Kroah-Hartman <gregkh@suse.de>, "David S. Miller" <davem@davemloft.net>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, "John W. Linville" <linville@tuxdriver.com>, Mauro Carvalho Chehab <mchehab@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>

On Wed 10-08-11 22:59:29, Raghavendra K T wrote:
[...]
> This patch renames all mem variables to memcg in source file.

__mem_cgroup_try_charge for example uses local mem which cannot be
renamed because it already has a memcg argument (mem_cgroup **) then we
have mem_cgroup_try_charge_swapin and mem_cgroup_prepare_migration which
use mem_cgroup **ptr (I guess we shouldn't have more of them).
I think that __mem_cgroup_try_charge should use ptr pattern as well.
Other than that I think the clean up is good.

With __mem_cgroup_try_charge:
Acked-by: Michal Hocko <mhocko@suse.cz>

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
