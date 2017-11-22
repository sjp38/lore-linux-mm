Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id B26576B0038
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 19:37:11 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 190so14392893pgh.16
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 16:37:11 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id l5si12241260pli.480.2017.11.21.16.37.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Nov 2017 16:37:10 -0800 (PST)
Subject: Re: [PATCH 12/30] x86, kaiser: map GDT into user page tables
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
 <20171110193125.EBF58596@viggo.jf.intel.com>
 <alpine.DEB.2.20.1711202115190.2348@nanos>
 <CALCETrVtXQbcTx6ZAjZGL3D8Z0OootVuP7saUdheBsW+mN6cvw@mail.gmail.com>
 <f71ce70f-ea43-d22f-1a2a-fdf4e9dab6af@linux.intel.com>
 <CBD89E9B-C146-42AE-A117-507C01CBF885@amacapital.net>
 <02e48e97-5842-6a19-1ea2-cee4ed5910f4@linux.intel.com>
 <CALCETrXk=qk=aeaXT+bZWoA2teEtavNnFNTE+o9kh7_As9bmpQ@mail.gmail.com>
 <62d71c5c-515e-c3be-e8f0-4f640251d20c@linux.intel.com>
 <CALCETrWqWBMzC_a2bRiTd+dxZQaK+ubhDof-nL06_RG3O1W4gQ@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <138a0a86-8bba-b372-5e4a-923633514967@linux.intel.com>
Date: Tue, 21 Nov 2017 16:37:07 -0800
MIME-Version: 1.0
In-Reply-To: <CALCETrWqWBMzC_a2bRiTd+dxZQaK+ubhDof-nL06_RG3O1W4gQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On 11/21/2017 04:17 PM, Andy Lutomirski wrote:
> On Tue, Nov 21, 2017 at 3:42 PM, Dave Hansen
> unsigned long start = (unsigned long)get_cpu_entry_area(cpu);
> for (unsigned long addr = start; addr < start + sizeof(struct
> cpu_entry_area); addr += PAGE_SIZE) {
>   pte_t pte = *pte_offset_k(addr);  /* or however you do this */
>   kaiser_add_mapping(pte_pfn(pte), pte_prot(pte));
> }
> 
> modulo the huge pile of typos in there that surely exist.

That would work.  I just need to find a suitable pte_offset_k() in the
kernel and make sure it works for these purposes.  We probably have one.

> But I still prefer my approach of just sharing the cpu_entry_area pmd
> entries between the user and kernel tables.

That would be spiffy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
