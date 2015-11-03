Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1E9EF6B0253
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 18:14:28 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so7399154pac.3
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 15:14:27 -0800 (PST)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id yb1si45565812pab.179.2015.11.03.15.14.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Nov 2015 15:14:27 -0800 (PST)
Received: by padhx2 with SMTP id hx2so23855032pad.1
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 15:14:27 -0800 (PST)
Subject: Re: [PATCH v2 2/2] arm: mm: support ARCH_MMAP_RND_BITS.
References: <1446574204-15567-1-git-send-email-dcashman@android.com>
 <1446574204-15567-2-git-send-email-dcashman@android.com>
 <CAGXu5jKGzDD9WVQnMTT2EfupZtjpdcASUpx-3npLAB-FctLodA@mail.gmail.com>
From: Daniel Cashman <dcashman@android.com>
Message-ID: <56393FD0.6080001@android.com>
Date: Tue, 3 Nov 2015 15:14:24 -0800
MIME-Version: 1.0
In-Reply-To: <CAGXu5jKGzDD9WVQnMTT2EfupZtjpdcASUpx-3npLAB-FctLodA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Jonathan Corbet <corbet@lwn.net>, Don Zickus <dzickus@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Heinrich Schuchardt <xypron.glpk@gmx.de>, jpoimboe@redhat.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, n-horiguchi@ah.jp.nec.com, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Thomas Gleixner <tglx@linutronix.de>, David Rientjes <rientjes@google.com>, Linux-MM <linux-mm@kvack.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Mark Salyzyn <salyzyn@android.com>, Jeffrey Vander Stoep <jeffv@google.com>, Nick Kralevich <nnk@google.com>, dcashman <dcashman@google.com>

On 11/03/2015 11:19 AM, Kees Cook wrote:
> Do you have patches for x86 and arm64? 

I was holding off on those until I could gauge upstream reception.  If
desired, I could put those together and add them as [PATCH 3/4] and
[PATCH 4/4].

Thank You,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
