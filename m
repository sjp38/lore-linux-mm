Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 1DDBC6B004D
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 04:44:06 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 9 Apr 2012 08:36:35 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q398bQO83629104
	for <linux-mm@kvack.org>; Mon, 9 Apr 2012 18:37:26 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q398hocn005498
	for <linux-mm@kvack.org>; Mon, 9 Apr 2012 18:43:51 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V5 07/14] memcg: Add HugeTLB extension
In-Reply-To: <4F827BF9.2090205@jp.fujitsu.com>
References: <1333738260-1329-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1333738260-1329-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <4F827BF9.2090205@jp.fujitsu.com>User-Agent: Notmuch/0.11.1+346~g13d19c3 (http://notmuchmail.org) Emacs/23.3.1 (x86_64-pc-linux-gnu)
Date: Mon, 09 Apr 2012 14:13:45 +0530
Message-ID: <87zkalcn26.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:

> (2012/04/07 3:50), Aneesh Kumar K.V wrote:
>
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> This patch implements a memcg extension that allows us to control HugeTLB
>> allocations via memory controller. The extension allows to limit the
>> HugeTLB usage per control group and enforces the controller limit during
>> page fault. Since HugeTLB doesn't support page reclaim, enforcing the limit
>> at page fault time implies that, the application will get SIGBUS signal if it
>> tries to access HugeTLB pages beyond its limit. This requires the application
>> to know beforehand how much HugeTLB pages it would require for its use.
>> 
>> The charge/uncharge calls will be added to HugeTLB code in later patch.
>> 
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>
>
> Hmm, seems ok to me. please explain 'this patch doesn't include updates
> for memcg destroying, it will be in patch 12/14' or some...
>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
>
> BTW, you don't put res_counter for hugeltb under CONFIG_MEM_RES_CTLR_HUGETLB...
> do you think we need the config ?


That results in more #ifdef CONFIG_MEM_RES_CTLR_HUGETLB in the
memcg code (mem_cgroup_create/mem_cgroup_read/write etc). I was not
sure we want to do that. Let me know if you think we really need to do this.


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
