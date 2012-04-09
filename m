Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 5196A6B004D
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 05:01:56 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 756E43EE0AE
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 18:01:54 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D27245DE5D
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 18:01:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 44D6E45DE5C
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 18:01:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 35C6C1DB8051
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 18:01:50 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E21E91DB8046
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 18:01:49 +0900 (JST)
Message-ID: <4F82A510.5030004@jp.fujitsu.com>
Date: Mon, 09 Apr 2012 18:00:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH -V5 07/14] memcg: Add HugeTLB extension
References: <1333738260-1329-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1333738260-1329-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <4F827BF9.2090205@jp.fujitsu.com>User-Agent: Notmuch/0.11.1+346~g13d19c3 (http://notmuchmail.org) Emacs/23.3.1 (x86_64-pc-linux-gnu) <87zkalcn26.fsf@skywalker.in.ibm.com>
In-Reply-To: <87zkalcn26.fsf@skywalker.in.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

(2012/04/09 17:43), Aneesh Kumar K.V wrote:

> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:
> 
>> (2012/04/07 3:50), Aneesh Kumar K.V wrote:
>>
>>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>>>
>>> This patch implements a memcg extension that allows us to control HugeTLB
>>> allocations via memory controller. The extension allows to limit the
>>> HugeTLB usage per control group and enforces the controller limit during
>>> page fault. Since HugeTLB doesn't support page reclaim, enforcing the limit
>>> at page fault time implies that, the application will get SIGBUS signal if it
>>> tries to access HugeTLB pages beyond its limit. This requires the application
>>> to know beforehand how much HugeTLB pages it would require for its use.
>>>
>>> The charge/uncharge calls will be added to HugeTLB code in later patch.
>>>
>>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>>
>>
>> Hmm, seems ok to me. please explain 'this patch doesn't include updates
>> for memcg destroying, it will be in patch 12/14' or some...
>>
>> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>>
>> BTW, you don't put res_counter for hugeltb under CONFIG_MEM_RES_CTLR_HUGETLB...
>> do you think we need the config ?
> 
> 
> That results in more #ifdef CONFIG_MEM_RES_CTLR_HUGETLB in the
> memcg code (mem_cgroup_create/mem_cgroup_read/write etc). I was not
> sure we want to do that. Let me know if you think we really need to do this.
> 


Hm. ok. BTW, how about removing all CONFIG_MEM_RES_CTLR_HUGETLB and makes 
all codes just depends on CONFIG_CGROUP_MEM_RES_CTLR && CONFIG_HUGETLB ?

How other guys thinks ? (Anyway we can do it later....)

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
