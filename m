Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 473CE6B0255
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 18:24:02 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so59408261pac.3
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 15:24:02 -0800 (PST)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id ax2si7501594pbc.170.2015.11.18.15.24.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 15:24:01 -0800 (PST)
Received: by pacej9 with SMTP id ej9so59357689pac.2
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 15:24:01 -0800 (PST)
Subject: Re: [PATCH 1/4] mm: mmap: Add new /proc tunable for mmap_base ASLR.
References: <1447886901-26098-1-git-send-email-dcashman@android.com>
 <1447886901-26098-2-git-send-email-dcashman@android.com>
 <CAGXu5jL7GXKqj1UTpwEwtZ_kKpeorA0fz84Pq=15kdZ3vGytQA@mail.gmail.com>
From: Daniel Cashman <dcashman@android.com>
Message-ID: <564D088E.7060409@android.com>
Date: Wed, 18 Nov 2015 15:23:58 -0800
MIME-Version: 1.0
In-Reply-To: <CAGXu5jL7GXKqj1UTpwEwtZ_kKpeorA0fz84Pq=15kdZ3vGytQA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Jonathan Corbet <corbet@lwn.net>, Don Zickus <dzickus@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Heinrich Schuchardt <xypron.glpk@gmx.de>, jpoimboe@redhat.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, n-horiguchi@ah.jp.nec.com, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Thomas Gleixner <tglx@linutronix.de>, David Rientjes <rientjes@google.com>, Linux-MM <linux-mm@kvack.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Mark Salyzyn <salyzyn@android.com>, Jeffrey Vander Stoep <jeffv@google.com>, Nick Kralevich <nnk@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, Hector Marco <hecmargi@upv.es>, Borislav Petkov <bp@suse.de>, Daniel Cashman <dcashman@google.com>

> I think the min/max values should be const, since they're determined
> at build time and should never change.

Ok. Also, I just submitted the patch-set again with [PATCH v3] instead
of [PATCH] so I'd prefer discussion there; sorry for the mistake.

-Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
