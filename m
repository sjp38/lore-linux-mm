Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E21CC6B0038
	for <linux-mm@kvack.org>; Thu, 11 May 2017 23:35:27 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id d11so37737000pgn.9
        for <linux-mm@kvack.org>; Thu, 11 May 2017 20:35:27 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x11si1971543pls.74.2017.05.11.20.35.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 May 2017 20:35:27 -0700 (PDT)
Received: from mail-ua0-f173.google.com (mail-ua0-f173.google.com [209.85.217.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8503C239AD
	for <linux-mm@kvack.org>; Fri, 12 May 2017 03:35:26 +0000 (UTC)
Received: by mail-ua0-f173.google.com with SMTP id j17so39998722uag.3
        for <linux-mm@kvack.org>; Thu, 11 May 2017 20:35:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170511174128.rp7dwckpci4gqsxy@pd.tnic>
References: <cover.1494160201.git.luto@kernel.org> <dbe03b624fb5e785d33ca71c98f113f05d7b12df.1494160201.git.luto@kernel.org>
 <20170511174128.rp7dwckpci4gqsxy@pd.tnic>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 11 May 2017 20:35:05 -0700
Message-ID: <CALCETrWa0UwpDCdBL740FEC4LgO=vaH88HjdQdAJrHtQR65wGA@mail.gmail.com>
Subject: Re: [RFC 01/10] x86/mm: Reimplement flush_tlb_page() using flush_tlb_mm_range()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>

On Thu, May 11, 2017 at 10:41 AM, Borislav Petkov <bp@suse.de> wrote:
>> +{
>> +     flush_tlb_mm_range(vma->vm_mm, a, a + PAGE_SIZE, 0);
>
>                                                          VM_NONE);
>

Fixed, although this won't have any effect.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
