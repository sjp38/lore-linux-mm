Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 1D7AF6B0034
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 10:24:54 -0400 (EDT)
Message-ID: <51F67B27.9040004@parallels.com>
Date: Mon, 29 Jul 2013 18:24:39 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Save soft-dirty bits on file pages
References: <20130726201807.GJ8661@moon> <51F67777.6060609@parallels.com> <20130729141417.GM2524@moon>
In-Reply-To: <20130729141417.GM2524@moon>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>

On 07/29/2013 06:14 PM, Cyrill Gorcunov wrote:
> On Mon, Jul 29, 2013 at 06:08:55PM +0400, Pavel Emelyanov wrote:
>>>  
>>> -	if (!pte_none(*pte))
>>> +	ptfile = pgoff_to_pte(pgoff);
>>> +
>>> +	if (!pte_none(*pte)) {
>>> +#ifdef CONFIG_MEM_SOFT_DIRTY
>>> +		if (pte_present(*pte) &&
>>> +		    pte_soft_dirty(*pte))
>>
>> I think there's no need in wrapping every such if () inside #ifdef CONFIG_...,
>> since the pte_soft_dirty() routine itself would be 0 for non-soft-dirty case
>> and compiler would optimize this code out.
> 
> If only I'm not missing something obvious, this code compiles not only on x86,
> CONFIG_MEM_SOFT_DIRTY depends on x86 (otherwise I'll have to implement
> pte_soft_dirty for all archs).

For non-x86 case there are stubs in include/asm-generic/pgtable.h that would
act as if the CONFIG_MEM_SOFT_DIRTY is off.

Thanks,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
