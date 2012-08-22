Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 8FA5A6B005D
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 01:38:12 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Wed, 22 Aug 2012 11:08:08 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7M5c2T59502750
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 11:08:04 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7M5c2Lm032506
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 15:38:02 +1000
Message-ID: <50347037.3040209@linux.vnet.ibm.com>
Date: Wed, 22 Aug 2012 13:37:59 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: mmu_notifier: fix inconsistent memory between secondary
 MMU and host
References: <503358FF.3030009@linux.vnet.ibm.com> <20120821150618.GJ27696@redhat.com> <50345735.2000807@linux.vnet.ibm.com> <alpine.LSU.2.00.1208212105370.3415@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1208212105370.3415@eggly.anvils>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Avi Kivity <avi@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>, LKML <linux-kernel@vger.kernel.org>, KVM <kvm@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On 08/22/2012 12:12 PM, Hugh Dickins wrote:
> On Wed, 22 Aug 2012, Xiao Guangrong wrote:
>> On 08/21/2012 11:06 PM, Andrea Arcangeli wrote:
>>>
>>> The KSM usage of it looks safe because it will only establish readonly
>>> ptes with it.
>>
>> Hmm, in KSM code, i found this code in replace_page:
>>
>> set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
>>
>> It is possible to establish a writable pte, no?
> 
> No: we only do KSM in private vmas (!VM_SHARED), and because of the
> need to CopyOnWrite in those, vm_page_prot excludes write permission:
> write permission has to be added on COW fault.

After read the code carefully, yes, you are right. Thank you very much
for your explanation, Hugh! :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
