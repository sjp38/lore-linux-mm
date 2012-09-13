Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id A782F6B0130
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 05:26:14 -0400 (EDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Thu, 13 Sep 2012 14:56:11 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q8D9Q98J36110548
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 14:56:09 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q8D9Q814007022
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 19:26:08 +1000
Message-ID: <5051A6AE.4090801@linux.vnet.ibm.com>
Date: Thu, 13 Sep 2012 17:26:06 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 09/12] thp: introduce khugepaged_prealloc_page and khugepaged_alloc_page
References: <5028E12C.70101@linux.vnet.ibm.com> <5028E20C.3080607@linux.vnet.ibm.com> <alpine.LSU.2.00.1209111807030.21798@eggly.anvils> <50500360.5020700@linux.vnet.ibm.com> <alpine.LSU.2.00.1209122316200.7831@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1209122316200.7831@eggly.anvils>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On 09/13/2012 02:27 PM, Hugh Dickins wrote:
> On Wed, 12 Sep 2012, Xiao Guangrong wrote:
>> On 09/12/2012 10:03 AM, Hugh Dickins wrote:
>>
>>> What brought me to look at it was hitting "BUG at mm/huge_memory.c:1842!"
>>> running tmpfs kbuild swapping load (with memcg's memory.limit_in_bytes
>>> forcing out to swap), while I happened to have CONFIG_NUMA=y.
>>>
>>> That's the VM_BUG_ON(*hpage) on entry to khugepaged_alloc_page().
>>
>>>
>>> So maybe 9/12 is just obscuring what was already a BUG, either earlier
>>> in your series or elsewhere in mmotm (I've never seen it on 3.6-rc or
>>> earlier releases, nor without CONFIG_NUMA).  I've not spent any time
>>> looking for it, maybe it's obvious - can you spot and fix it?
>>
>> Hugh,
>>
>> I think i have already found the reason,
> 
> Great, thank you.
> 
>> if i am correct, the bug was existing before my patch.
> 
> Before your patchset?  Are you sure of that?

No. :)

I have told Andrew that the fix patch need not back port in
0/3. Sorry again for my mistake.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
