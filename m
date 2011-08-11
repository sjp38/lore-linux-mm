Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6E5B490013B
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 04:58:17 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp06.in.ibm.com (8.14.4/8.13.1) with ESMTP id p7B8vvsx009888
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 14:27:57 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p7B8vTYo3678308
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 14:27:31 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p7B8v6Dm017574
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 18:57:07 +1000
Message-ID: <4E439962.4040105@linux.vnet.ibm.com>
Date: Thu, 11 Aug 2011 14:27:06 +0530
From: Raghavendra K T <raghukt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2][cleanup] memcg: renaming of mem variable to memcg
References: <20110810172917.23280.9440.sendpatchset@oc5400248562.ibm.com> <20110810172929.23280.76419.sendpatchset@oc5400248562.ibm.com> <20110811080447.GB8023@tiehlicka.suse.cz>
In-Reply-To: <20110811080447.GB8023@tiehlicka.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Arend van Spriel <arend@broadcom.com>, Greg Kroah-Hartman <gregkh@suse.de>, "David S. Miller" <davem@davemloft.net>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, "John W. Linville" <linville@tuxdriver.com>, Mauro Carvalho Chehab <mchehab@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>

On 08/11/2011 01:34 PM, Michal Hocko wrote:
> On Wed 10-08-11 22:59:29, Raghavendra K T wrote:
> [...]
>> This patch renames all mem variables to memcg in source file.
>
> __mem_cgroup_try_charge for example uses local mem which cannot be
> renamed because it already has a memcg argument (mem_cgroup **) then we
> have mem_cgroup_try_charge_swapin and mem_cgroup_prepare_migration which
> use mem_cgroup **ptr (I guess we shouldn't have more of them).
> I think that __mem_cgroup_try_charge should use ptr pattern as well.
> Other than that I think the clean up is good.
>
> With __mem_cgroup_try_charge:
> Acked-by: Michal Hocko<mhocko@suse.cz>
>
> Thanks
Agreed, Let me know whether you prefer whole patch to be posted or only 
the corresponding hunk.
Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
