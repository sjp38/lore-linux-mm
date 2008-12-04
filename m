Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB4Cir8X020056
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 4 Dec 2008 21:44:53 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 76AFE45DE4F
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 21:44:53 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 563F845DE4E
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 21:44:53 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F1F11DB803F
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 21:44:53 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id EFDCC1DB803A
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 21:44:52 +0900 (JST)
Message-ID: <44799.10.75.179.61.1228394692.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20081204200037.63ff03c9.nishimura@mxp.nes.nec.co.jp>
References: <20081203134718.6b60986f.kamezawa.hiroyu@jp.fujitsu.com><20081203141423.6f747990.kamezawa.hiroyu@jp.fujitsu.com>
    <20081204200037.63ff03c9.nishimura@mxp.nes.nec.co.jp>
Date: Thu, 4 Dec 2008 21:44:52 +0900 (JST)
Subject: Re: [Experimental][PATCH  
     21/21]memcg-new-hierarchical-reclaim.patch
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=us-ascii
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura said:
> On Wed, 3 Dec 2008 14:14:23 +0900, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> Implement hierarchy reclaim by cgroup_id.

>> +	rcu_read_lock();
>> +	if (!root_mem->use_hierarchy) {
>> +		spin_lock(&root_mem->reclaim_param_lock);
>> +		root_mem->scan_age++;
>> +		spin_unlock(&root_mem->reclaim_param_lock);
>> +		css_get(&root_mem->css);
>> +		goto out;
>>  	}
>>
> I think you forgot "ret = root_mem".
> I got NULL pointer dereference BUG in my test(I've not tested
> use_hierarchy case yet).
>
yes...thank you for catching. will fix.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
