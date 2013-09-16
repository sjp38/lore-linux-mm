Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id A6AE16B003C
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 12:16:43 -0400 (EDT)
Received: by mail-ob0-f173.google.com with SMTP id vb8so4020028obc.4
        for <linux-mm@kvack.org>; Mon, 16 Sep 2013 09:16:42 -0700 (PDT)
Message-ID: <52372EEF.7050608@gmail.com>
Date: Mon, 16 Sep 2013 12:16:47 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm/shmem.c: check the return value of mpol_to_str()
References: <5215639D.1080202@asianux.com> <5227CF48.5080700@asianux.com> <alpine.DEB.2.02.1309091326210.16291@chino.kir.corp.google.com> <522E6C14.7060006@asianux.com> <alpine.DEB.2.02.1309092334570.20625@chino.kir.corp.google.com> <522EC3D1.4010806@asianux.com> <alpine.DEB.2.02.1309111725290.22242@chino.kir.corp.google.com> <52312EC1.8080300@asianux.com> <523205A0.1000102@gmail.com> <5232773E.8090007@asianux.com> <5233424A.2050704@gmail.com> <5236732C.5060804@asianux.com>
In-Reply-To: <5236732C.5060804@asianux.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, riel@redhat.com, hughd@google.com, xemul@parallels.com, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

(9/15/13 10:55 PM), Chen Gang wrote:
> On 09/14/2013 12:50 AM, KOSAKI Motohiro wrote:
>>> ---
>>>    mm/shmem.c |    2 +-
>>>    1 files changed, 1 insertions(+), 1 deletions(-)
>>>
>>> diff --git a/mm/shmem.c b/mm/shmem.c
>>> index 8612a95..3f81120 100644
>>> --- a/mm/shmem.c
>>> +++ b/mm/shmem.c
>>> @@ -890,7 +890,7 @@ static void shmem_show_mpol(struct seq_file *seq,
>>> struct mempolicy *mpol)
>>>        if (!mpol || mpol->mode == MPOL_DEFAULT)
>>>            return;        /* show nothing */
>>>
>>> -    mpol_to_str(buffer, sizeof(buffer), mpol);
>>> +    VM_BUG_ON(mpol_to_str(buffer, sizeof(buffer), mpol) < 0);
>>
>> NAK. VM_BUG_ON is a kind of assertion. It erase the contents if
>> CONFIG_DEBUG_VM not set.
>> An argument of assertion should not have any side effect.
>
> Oh, really it is. In my opinion, need use "BUG_ON(mpol_to_str() < 0)"
> instead of "VM_BUG_ON(mpol_to_str() < 0);".

BUG_ON() is safe. but I still don't like it. As far as I heard, Google
changes BUG_ON as nop. So, BUG_ON(mpol_to_str() < 0) breaks google.
Please treat an assertion as assertion. Not any other something.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
