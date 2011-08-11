Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6A95A6B0170
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 04:16:48 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp08.au.ibm.com (8.14.4/8.13.1) with ESMTP id p7B8BGpc017937
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 18:11:16 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p7B8GPna1278024
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 18:16:25 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p7B8GNFl022289
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 18:16:24 +1000
Message-ID: <4E438FD3.7070000@linux.vnet.ibm.com>
Date: Thu, 11 Aug 2011 13:46:19 +0530
From: Raghavendra K T <raghukt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2][cleanup] memcg: renaming of mem variable to memcg
References: <20110810172917.23280.9440.sendpatchset@oc5400248562.ibm.com> <20110811075337.GA8023@tiehlicka.suse.cz>
In-Reply-To: <20110811075337.GA8023@tiehlicka.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Arend van Spriel <arend@broadcom.com>, Greg Kroah-Hartman <gregkh@suse.de>, "David S. Miller" <davem@davemloft.net>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, "John W. Linville" <linville@tuxdriver.com>, Mauro Carvalho Chehab <mchehab@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>

On 08/11/2011 01:23 PM, Michal Hocko wrote:
> On Wed 10-08-11 22:59:17, Raghavendra K T wrote:
>> Hi,
>>   This is the memcg cleanup patch for that was talked little ago to change the  "struct
>>   mem_cgroup *mem" variable to  "struct mem_cgroup *memcg".
>>
>>   The patch is though trivial, it is huge one.
>>   Testing : Compile tested with following configurations.
>>   1) CONFIG_CGROUP_MEM_RES_CTLR=y  CONFIG_CGROUP_MEM_RES_CTLR_SWAP=y
>>   2) CONFIG_CGROUP_MEM_RES_CTLR=y  CONFIG_CGROUP_MEM_RES_CTLR_SWAP=n
>>   3) CONFIG_CGROUP_MEM_RES_CTLR=n  CONFIG_CGROUP_MEM_RES_CTLR_SWAP=n
>
> How exactly have you tested? Compiled and compared before/after binaries
> (it shouldn't change, right)?
Yes, But idea was to ensure that both #ifdef and #else part are hit 
during compilation, which could expose some corrections needed.
>
>>
>>   Also tested basic mounting with memcgroup.
>>   Raghu.
>
> Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
