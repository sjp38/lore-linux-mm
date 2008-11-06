Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA6CiNQC023955
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 6 Nov 2008 21:44:23 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DFEF845DD80
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 21:44:22 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BA42245DD7C
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 21:44:22 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9FE691DB803B
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 21:44:22 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 563041DB803A
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 21:44:22 +0900 (JST)
Message-ID: <29542.10.75.179.61.1225975461.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20081106202534.80e5cf0a.nishimura@mxp.nes.nec.co.jp>
References: <20081105171637.1b393333.kamezawa.hiroyu@jp.fujitsu.com><20081105172141.1a12dc23.kamezawa.hiroyu@jp.fujitsu.com>
    <20081106202534.80e5cf0a.nishimura@mxp.nes.nec.co.jp>
Date: Thu, 6 Nov 2008 21:44:21 +0900 (JST)
Subject: Re: [RFC][PATCH 4/6] memcg : swap cgroup
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=us-ascii
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura said:
> On Wed, 5 Nov 2008 17:21:41 +0900, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> Note1: In this, we use pointer to record information and this means
>>       8bytes per swap entry. I think we can reduce this when we
>>       create "id of cgroup" in the range of 0-65535 or 0-255.
>>
>> Note2: array of swap_cgroup is allocated from HIGHMEM. maybe good for
>> x86-32.
>>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>>  include/linux/page_cgroup.h |   35 +++++++
>>  mm/page_cgroup.c            |  201
>> ++++++++++++++++++++++++++++++++++++++++++++
>>  mm/swapfile.c               |    8 +
>>  3 files changed, 244 insertions(+)
>>
> Is there any reason why they are defined not in memcontrol.[ch]
> but in page_cgroup.[ch]?
>
no strong reason. just because this is not core logic for acccounting.
do you want to see this in memcontrol.c ?

>> +void swap_cgroup_swapoff(int type)
>> +{
>> +	int i;
>> +	struct swap_cgroup_ctrl *ctrl;
>> +
>> +	if (!do_swap_account)
>> +		return;
>> +
>> +	mutex_lock(&swap_cgroup_mutex);
>> +	if (ctrl->map) {
>> +		ctrl = &swap_cgroup_ctrl[type];
> This line should be before "if (ctrl->map)"(otherwise "ctrl" will be
> undefined!).
>
Oh....maybe refresh mis...brame me.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
