Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id DCEA96B000D
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 10:08:35 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id v7-v6so5474892plo.23
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 07:08:35 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id q1-v6si1770720pfb.258.2018.10.03.07.08.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 07:08:34 -0700 (PDT)
Subject: Re: [RFC PATCH v4 09/27] x86/mm: Change _PAGE_DIRTY to _PAGE_DIRTY_HW
References: <20180921150351.20898-1-yu-cheng.yu@intel.com>
 <20180921150351.20898-10-yu-cheng.yu@intel.com>
 <20181003133856.GA24782@bombadil.infradead.org>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <688c3f90-f86e-32e8-ce1a-7a10facb08a8@linux.intel.com>
Date: Wed, 3 Oct 2018 07:05:23 -0700
MIME-Version: 1.0
In-Reply-To: <20181003133856.GA24782@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On 10/03/2018 06:38 AM, Matthew Wilcox wrote:
> On Fri, Sep 21, 2018 at 08:03:33AM -0700, Yu-cheng Yu wrote:
>> We are going to create _PAGE_DIRTY_SW for non-hardware, memory
>> management purposes.  Rename _PAGE_DIRTY to _PAGE_DIRTY_HW and
>> _PAGE_BIT_DIRTY to _PAGE_BIT_DIRTY_HW to make these PTE dirty
>> bits more clear.  There are no functional changes in this
>> patch.
> I would like there to be some documentation in this patchset which
> explains the difference between PAGE_SOFT_DIRTY and PAGE_DIRTY_SW.
> 
> Also, is it really necessary to rename PAGE_DIRTY?  It feels like a
> lot of churn.

This is a lot of churn?  Are we looking a the same patch? :)

 arch/x86/include/asm/pgtable.h       |  6 +++---
 arch/x86/include/asm/pgtable_types.h | 17 +++++++++--------
 arch/x86/kernel/relocate_kernel_64.S |  2 +-
 arch/x86/kvm/vmx.c                   |  2 +-
 4 files changed, 14 insertions(+), 13 deletions(-)

But, yeah, I think we need to.  While it will take a little adjustment
in the brains of us old-timers and a bit of pain when switching from old
kernels to new, this makes it a lot more clear what is going on.
