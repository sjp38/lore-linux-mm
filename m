Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 53F766B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 16:35:26 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so6015200pab.4
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 13:35:26 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id z9si28242558par.226.2015.01.13.13.35.24
        for <linux-mm@kvack.org>;
        Tue, 13 Jan 2015 13:35:25 -0800 (PST)
Message-ID: <54B58F9B.4050100@linux.intel.com>
Date: Tue, 13 Jan 2015 13:35:23 -0800
From: Dave Hansen <dave.hansen@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: rename mm->nr_ptes to mm->nr_pgtables
References: <1421176456-21796-1-git-send-email-kirill.shutemov@linux.intel.com> <1421176456-21796-2-git-send-email-kirill.shutemov@linux.intel.com> <54B581C7.50206@linux.intel.com> <20150113204144.GA1865@node.dhcp.inet.fi>
In-Reply-To: <20150113204144.GA1865@node.dhcp.inet.fi>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@openvz.org>, linux-kernel@vger.kernel.org

On 01/13/2015 12:41 PM, Kirill A. Shutemov wrote:
> On Tue, Jan 13, 2015 at 12:36:23PM -0800, Dave Hansen wrote:
>> On 01/13/2015 11:14 AM, Kirill A. Shutemov wrote:
>>>  	pgd_t * pgd;
>>>  	atomic_t mm_users;			/* How many users with user space? */
>>>  	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
>>> -	atomic_long_t nr_ptes;			/* Page table pages */
>>> +	atomic_long_t nr_pgtables;		/* Page table pages */
>>>  	int map_count;				/* number of VMAs */
>>
>> One more crazy idea...
>>
>> There are 2^9 possible pud pages, 2^18 pmd pages and 2^27 pte pages.
>> That's only 54 bits (technically minus one bit each because the upper
>> half of the address space is for the kernel).
> 
> Does this math make sense for all architecures? IA64? Power?

No, the sizes will be different on the other architectures.  But, 4k
pages with 64-bit ptes is as bad as it gets, I think.  Larger page sizes
mean fewer page tables on powerpc.  So the values should at least _fit_
in a long.

Maybe it's not even worth the trouble.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
