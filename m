Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 8B58C6B0007
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 17:23:52 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Tue, 5 Feb 2013 17:23:51 -0500
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id B7DEE38C801F
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 17:23:47 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r15MNlfi25559072
	for <linux-mm@kvack.org>; Tue, 5 Feb 2013 17:23:47 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r15MNkqf025647
	for <linux-mm@kvack.org>; Tue, 5 Feb 2013 20:23:47 -0200
Message-ID: <51118671.7020204@linux.vnet.ibm.com>
Date: Tue, 05 Feb 2013 14:23:45 -0800
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/9] mm: add SECTION_IN_PAGE_FLAGS
References: <1358463181-17956-1-git-send-email-cody@linux.vnet.ibm.com> <1358463181-17956-2-git-send-email-cody@linux.vnet.ibm.com> <20130201162002.49eadeb7.akpm@linux-foundation.org>
In-Reply-To: <20130201162002.49eadeb7.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>, David Hansen <dave@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>

On 02/01/2013 04:20 PM, Andrew Morton wrote:
> On Thu, 17 Jan 2013 14:52:53 -0800
> Cody P Schafer <cody@linux.vnet.ibm.com> wrote:
>
>> Instead of directly utilizing a combination of config options to determine this,
>> add a macro to specifically address it.
>>
>> ...
>>
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -625,6 +625,10 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
>>   #define NODE_NOT_IN_PAGE_FLAGS
>>   #endif
>>
>> +#if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
>> +#define SECTION_IN_PAGE_FLAGS
>> +#endif
>
> We could do this in Kconfig itself, in the definition of a new
> CONFIG_SECTION_IN_PAGE_FLAGS.

Yep, I only put it here because it "sounds" the similar to 
NODE_NOT_IN_PAGE_FLAGS, but (of course) NODE_NOT_IN_PAGE_FLAGS isn't 
defined based on pure dependencies, while this is.

> I'm not sure that I like that sort of thing a lot though - it's rather a
> pain to have to switch from .[ch] over to Kconfig to find the
> definitions of things.  I should get off my tail and teach my ctags
> scripts to handle this.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
