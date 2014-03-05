Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id B1ECF6B00B0
	for <linux-mm@kvack.org>; Tue,  4 Mar 2014 23:10:33 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id r10so496701pdi.21
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 20:10:33 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [203.10.76.45])
        by mx.google.com with ESMTPS id io5si952511pbc.174.2014.03.04.20.10.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Mar 2014 20:10:32 -0800 (PST)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCHv3 1/2] mm: introduce vm_ops->map_pages()
In-Reply-To: <20140303151611.5671eebb74cedb99aa5396c8@linux-foundation.org>
References: <1393530827-25450-1-git-send-email-kirill.shutemov@linux.intel.com> <1393530827-25450-2-git-send-email-kirill.shutemov@linux.intel.com> <20140303151611.5671eebb74cedb99aa5396c8@linux-foundation.org>
Date: Wed, 05 Mar 2014 10:34:15 +1030
Message-ID: <8761nt1pfk.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ning Qu <quning@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> writes:
> On Thu, 27 Feb 2014 21:53:46 +0200 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
>> +
>> +void do_set_pte(struct vm_area_struct *vma, unsigned long address,
>> +		struct page *page, pte_t *pte, bool write, bool anon);
>>  #endif
>>  
>>  /*
>
> lguest made a dubious naming decision:
>
> drivers/lguest/page_tables.c:890: error: conflicting types for 'do_set_pte'
> include/linux/mm.h:593: note: previous declaration of 'do_set_pte' was here
>
> I'll rename lguest's do_set_pte() to do_guest_set_pte() as a
> preparatory patch.

s/do_/ if you don't mind; if we're going to prefix it, we don't need the
extra verb.

Thanks,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
