Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0BE468D0039
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 12:11:22 -0500 (EST)
Message-ID: <4D63EE38.9000008@linux.intel.com>
Date: Tue, 22 Feb 2011 09:11:20 -0800
From: Andi Kleen <ak@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/8] Fix interleaving for transparent hugepages
References: <1298315270-10434-1-git-send-email-andi@firstfloor.org> <1298315270-10434-2-git-send-email-andi@firstfloor.org> <alpine.DEB.2.00.1102220933500.16060@router.home>
In-Reply-To: <alpine.DEB.2.00.1102220933500.16060@router.home>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, lwoodman@redhat.com

On 2/22/2011 7:34 AM, Christoph Lameter wrote:
> On Mon, 21 Feb 2011, Andi Kleen wrote:
>
>> @@ -1830,7 +1830,7 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
>>   	if (unlikely(pol->mode == MPOL_INTERLEAVE)) {
>>   		unsigned nid;
>>
>> -		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT);
>> +		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT<<  order);
> Should be PAGE_SHIFT + order.

Oops. True. Thanks.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
