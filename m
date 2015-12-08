Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 98F4B6B0254
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 05:22:53 -0500 (EST)
Received: by wmec201 with SMTP id c201so205571262wme.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 02:22:53 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.131])
        by mx.google.com with ESMTPS id i7si3404374wjw.174.2015.12.08.02.22.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 02:22:52 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v5 3/4] arm64: mm: support ARCH_MMAP_RND_BITS.
Date: Tue, 08 Dec 2015 11:03:51 +0100
Message-ID: <7610963.Sys3aageLY@wuerfel>
In-Reply-To: <5665CF5A.1090207@android.com>
References: <1449000658-11475-1-git-send-email-dcashman@android.com> <1720878.JdEcLd8bhL@wuerfel> <5665CF5A.1090207@android.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: Daniel Cashman <dcashman@android.com>, Jon Hunter <jonathanh@nvidia.com>, linux-doc@vger.kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, linux-mm@kvack.org, hpa@zytor.com, mingo@kernel.org, aarcange@redhat.com, linux@arm.linux.org.uk, kirill.shutemov@linux.intel.com, corbet@lwn.net, xypron.glpk@gmx.de, x86@kernel.org, hecmargi@upv.es, mgorman@suse.de, rientjes@google.com, bp@suse.de, nnk@google.com, dzickus@redhat.com, keescook@chromium.org, jpoimboe@redhat.com, tglx@linutronix.de, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, salyzyn@android.com, ebiederm@xmission.com, jeffv@google.com, n-horiguchi@ah.jp.nec.com, dcashman@google.com

On Monday 07 December 2015 10:26:34 Daniel Cashman wrote:
> > Ideally we'd remove the #ifdef around the mmap_rnd_compat_bits declaration
> > and change this code to use
> > 
> >       if (IS_ENABLED(CONFIG_COMPAT) && test_thread_flag(TIF_32BIT))
> > 
> That would result in "undefined reference to mmap_rnd_compat_bits" in
> the not-defined case, no?

No. The compiler eliminates all code paths that it knows are unused.
The IS_ENABLED() macro is designed to let the compiler figure this out.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
