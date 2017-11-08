Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 29D1044043C
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 15:11:04 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id o7so3578675pgc.23
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 12:11:04 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id u3si80371pfl.4.2017.11.08.12.11.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Nov 2017 12:11:03 -0800 (PST)
Subject: Re: [PATCH 01/30] x86, mm: do not set _PAGE_USER for init_mm page
 tables
References: <20171108194646.907A1942@viggo.jf.intel.com>
 <20171108194647.ABC9BC79@viggo.jf.intel.com>
 <CA+55aFwuFT48RS=Bn9qvgjr+2r+jNroQHw1F+G_GxtU12nJmaw@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <d30dd5bc-ca45-6bd9-5671-12980e1b3d8c@linux.intel.com>
Date: Wed, 8 Nov 2017 12:11:01 -0800
MIME-Version: 1.0
In-Reply-To: <CA+55aFwuFT48RS=Bn9qvgjr+2r+jNroQHw1F+G_GxtU12nJmaw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, Andrew Lutomirski <luto@kernel.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, the arch/x86 maintainers <x86@kernel.org>

On 11/08/2017 11:52 AM, Linus Torvalds wrote:
> On Wed, Nov 8, 2017 at 11:46 AM, Dave Hansen
> <dave.hansen@linux.intel.com> wrote:
>>
>> +
>>  static inline void pmd_populate_kernel(struct mm_struct *mm,
>>                                        pmd_t *pmd, pte_t *pte)
>>  {
>> +       pteval_t pgtable_flags = mm_pgtable_flags(mm);
> 
> Why is "pmd_populate_kernel()" using mm_pgtable_flags(mm)?
> 
> It should just use _KERNPG_TABLE unconditionally, shouldn't it?
> Nothing to do with init_mm, it's populating a _kernel_ page table
> regardless, no?

The end result is probably the same since a quick grep shows it only
ever getting called with init_mm or NULL.  But, yeah, it should probably
just be _PAGE_KERNEL directly.

I'll update it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
