Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DF4FF831FE
	for <linux-mm@kvack.org>; Tue,  9 May 2017 18:54:31 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e131so11024425pfh.7
        for <linux-mm@kvack.org>; Tue, 09 May 2017 15:54:31 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id z5si1227734pgn.94.2017.05.09.15.54.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 May 2017 15:54:30 -0700 (PDT)
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 401D82028D
	for <linux-mm@kvack.org>; Tue,  9 May 2017 22:54:28 +0000 (UTC)
Received: from mail-ua0-f181.google.com (mail-ua0-f181.google.com [209.85.217.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E7904202BE
	for <linux-mm@kvack.org>; Tue,  9 May 2017 22:54:24 +0000 (UTC)
Received: by mail-ua0-f181.google.com with SMTP id e28so17211356uah.0
        for <linux-mm@kvack.org>; Tue, 09 May 2017 15:54:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1705092236290.2295@nanos>
References: <cover.1494160201.git.luto@kernel.org> <1a124281c99741606f1789140f9805beebb119da.1494160201.git.luto@kernel.org>
 <alpine.DEB.2.20.1705092236290.2295@nanos>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 9 May 2017 15:54:03 -0700
Message-ID: <CALCETrV5ogB0qx4Mp0yYBSDvOPOCnKT-NjVa-0TwFurC2XSKpg@mail.gmail.com>
Subject: Re: [RFC 09/10] x86/mm: Rework lazy TLB to track the actual loaded mm
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Arjan van de Ven <arjan@linux.intel.com>

On Tue, May 9, 2017 at 1:41 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> On Sun, 7 May 2017, Andy Lutomirski wrote:
>>  /* context.lock is held for us, so we don't need any locking. */
>>  static void flush_ldt(void *current_mm)
>>  {
>> +     struct mm_struct *mm = current_mm;
>>       mm_context_t *pc;
>>
>> -     if (current->active_mm != current_mm)
>> +     if (this_cpu_read(cpu_tlbstate.loaded_mm) != current_mm)
>
> While functional correct, this really should compare against 'mm'.
>

Fixed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
