Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id BDDD16B02AB
	for <linux-mm@kvack.org>; Tue, 15 May 2018 10:19:41 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id r9-v6so100173pgp.12
        for <linux-mm@kvack.org>; Tue, 15 May 2018 07:19:41 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id f7-v6si158226pfa.78.2018.05.15.07.19.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 May 2018 07:19:40 -0700 (PDT)
Subject: Re: [PATCH] mm: Add new vma flag VM_LOCAL_CPU
References: <0efb5547-9250-6b6c-fe8e-cf4f44aaa5eb@netapp.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <428e2683-42df-c810-eb5f-0c6841f50836@linux.intel.com>
Date: Tue, 15 May 2018 07:19:38 -0700
MIME-Version: 1.0
In-Reply-To: <0efb5547-9250-6b6c-fe8e-cf4f44aaa5eb@netapp.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boazh@netapp.com>, Jeff Moyer <jmoyer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Amit Golander <Amit.Golander@netapp.com>

On 05/14/2018 10:28 AM, Boaz Harrosh wrote:
> The VM_LOCAL_CPU flag tells the Kernel that the vma will be used
> from a single-core only, and therefore invalidation (flush_tlb) of
> PTE(s) need not be a wide CPU scheduling.

This doesn't work on x86.  We load TLB entries for lots of reasons, even
if the PTE is never "used".  Is there another architecture you had in
mind that has more predictable TLB population behavior?
