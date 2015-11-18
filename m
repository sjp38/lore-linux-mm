Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 79F496B0263
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 18:26:34 -0500 (EST)
Received: by ioir85 with SMTP id r85so71391465ioi.1
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 15:26:34 -0800 (PST)
Received: from mail-ig0-x22a.google.com (mail-ig0-x22a.google.com. [2607:f8b0:4001:c05::22a])
        by mx.google.com with ESMTPS id x9si8007483igl.12.2015.11.18.15.26.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 15:26:34 -0800 (PST)
Received: by igbxm8 with SMTP id xm8so51119747igb.1
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 15:26:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <564D088E.7060409@android.com>
References: <1447886901-26098-1-git-send-email-dcashman@android.com>
	<1447886901-26098-2-git-send-email-dcashman@android.com>
	<CAGXu5jL7GXKqj1UTpwEwtZ_kKpeorA0fz84Pq=15kdZ3vGytQA@mail.gmail.com>
	<564D088E.7060409@android.com>
Date: Wed, 18 Nov 2015 15:26:33 -0800
Message-ID: <CAGXu5j+7ShmxMmAG-DFrtL4PpXg8Nboh53ZFVZmcYzBg2kEVFw@mail.gmail.com>
Subject: Re: [PATCH 1/4] mm: mmap: Add new /proc tunable for mmap_base ASLR.
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Cashman <dcashman@android.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Jonathan Corbet <corbet@lwn.net>, Don Zickus <dzickus@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Heinrich Schuchardt <xypron.glpk@gmx.de>, jpoimboe@redhat.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, n-horiguchi@ah.jp.nec.com, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Thomas Gleixner <tglx@linutronix.de>, David Rientjes <rientjes@google.com>, Linux-MM <linux-mm@kvack.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Mark Salyzyn <salyzyn@android.com>, Jeffrey Vander Stoep <jeffv@google.com>, Nick Kralevich <nnk@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, Hector Marco <hecmargi@upv.es>, Borislav Petkov <bp@suse.de>, Daniel Cashman <dcashman@google.com>

On Wed, Nov 18, 2015 at 3:23 PM, Daniel Cashman <dcashman@android.com> wrote:
>> I think the min/max values should be const, since they're determined
>> at build time and should never change.
>
> Ok. Also, I just submitted the patch-set again with [PATCH v3] instead
> of [PATCH] so I'd prefer discussion there; sorry for the mistake.

Oops, yeah, just saw that come in after I already sent my comments. :P

-Kees

-- 
Kees Cook
Chrome OS Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
