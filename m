Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id CDC5D82F64
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 18:21:13 -0500 (EST)
Received: by igbdj2 with SMTP id dj2so23743897igb.1
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 15:21:13 -0800 (PST)
Received: from mail-ig0-x22c.google.com (mail-ig0-x22c.google.com. [2607:f8b0:4001:c05::22c])
        by mx.google.com with ESMTPS id om6si17232898igb.48.2015.11.03.15.21.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Nov 2015 15:21:13 -0800 (PST)
Received: by igbdj2 with SMTP id dj2so23743803igb.1
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 15:21:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56393FD0.6080001@android.com>
References: <1446574204-15567-1-git-send-email-dcashman@android.com>
	<1446574204-15567-2-git-send-email-dcashman@android.com>
	<CAGXu5jKGzDD9WVQnMTT2EfupZtjpdcASUpx-3npLAB-FctLodA@mail.gmail.com>
	<56393FD0.6080001@android.com>
Date: Tue, 3 Nov 2015 15:21:12 -0800
Message-ID: <CAGXu5jLe=OgZ2DG_MRXA8x6BwpEd77fNZBj3wjbDiSdiBurz7w@mail.gmail.com>
Subject: Re: [PATCH v2 2/2] arm: mm: support ARCH_MMAP_RND_BITS.
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Cashman <dcashman@android.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Jonathan Corbet <corbet@lwn.net>, Don Zickus <dzickus@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Heinrich Schuchardt <xypron.glpk@gmx.de>, jpoimboe@redhat.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, n-horiguchi@ah.jp.nec.com, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Thomas Gleixner <tglx@linutronix.de>, David Rientjes <rientjes@google.com>, Linux-MM <linux-mm@kvack.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Mark Salyzyn <salyzyn@android.com>, Jeffrey Vander Stoep <jeffv@google.com>, Nick Kralevich <nnk@google.com>, dcashman <dcashman@google.com>, Michael Ellerman <michael@ellerman.id.au>

On Tue, Nov 3, 2015 at 3:14 PM, Daniel Cashman <dcashman@android.com> wrote:
> On 11/03/2015 11:19 AM, Kees Cook wrote:
>> Do you have patches for x86 and arm64?
>
> I was holding off on those until I could gauge upstream reception.  If
> desired, I could put those together and add them as [PATCH 3/4] and
> [PATCH 4/4].

If they're as trivial as I'm hoping, yeah, let's toss them in now. If
not, skip 'em. PowerPC, MIPS, and s390 should be relatively simple
too, but one or two of those have somewhat stranger calculations when
I looked, so their Kconfigs may not be as clean.

-Kees

-- 
Kees Cook
Chrome OS Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
