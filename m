Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 529076B0093
	for <linux-mm@kvack.org>; Sun, 15 Sep 2013 22:56:45 -0400 (EDT)
Message-ID: <5236732C.5060804@asianux.com>
Date: Mon, 16 Sep 2013 10:55:40 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm/shmem.c: check the return value of mpol_to_str()
References: <5215639D.1080202@asianux.com> <5227CF48.5080700@asianux.com> <alpine.DEB.2.02.1309091326210.16291@chino.kir.corp.google.com> <522E6C14.7060006@asianux.com> <alpine.DEB.2.02.1309092334570.20625@chino.kir.corp.google.com> <522EC3D1.4010806@asianux.com> <alpine.DEB.2.02.1309111725290.22242@chino.kir.corp.google.com> <52312EC1.8080300@asianux.com> <523205A0.1000102@gmail.com> <5232773E.8090007@asianux.com> <5233424A.2050704@gmail.com>
In-Reply-To: <5233424A.2050704@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, riel@redhat.com, hughd@google.com, xemul@parallels.com, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On 09/14/2013 12:50 AM, KOSAKI Motohiro wrote:
>> ---
>>   mm/shmem.c |    2 +-
>>   1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/shmem.c b/mm/shmem.c
>> index 8612a95..3f81120 100644
>> --- a/mm/shmem.c
>> +++ b/mm/shmem.c
>> @@ -890,7 +890,7 @@ static void shmem_show_mpol(struct seq_file *seq,
>> struct mempolicy *mpol)
>>       if (!mpol || mpol->mode == MPOL_DEFAULT)
>>           return;        /* show nothing */
>>
>> -    mpol_to_str(buffer, sizeof(buffer), mpol);
>> +    VM_BUG_ON(mpol_to_str(buffer, sizeof(buffer), mpol) < 0);
> 
> NAK. VM_BUG_ON is a kind of assertion. It erase the contents if
> CONFIG_DEBUG_VM not set.
> An argument of assertion should not have any side effect.
> 
> 
> 

Oh, really it is. In my opinion, need use "BUG_ON(mpol_to_str() < 0)"
instead of "VM_BUG_ON(mpol_to_str() < 0);".


Thanks.
-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
