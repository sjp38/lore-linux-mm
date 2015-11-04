Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6DE656B0253
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 19:04:13 -0500 (EST)
Received: by igvi2 with SMTP id i2so79673637igv.0
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 16:04:13 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ax3si43266igc.53.2015.11.03.16.04.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Nov 2015 16:04:12 -0800 (PST)
Date: Tue, 3 Nov 2015 16:04:10 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/2] mm: mmap: Add new /proc tunable for mmap_base
 ASLR.
Message-Id: <20151103160410.34bbebc805c17d2f41150a19@linux-foundation.org>
In-Reply-To: <1446574204-15567-1-git-send-email-dcashman@android.com>
References: <1446574204-15567-1-git-send-email-dcashman@android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Cashman <dcashman@android.com>
Cc: linux-kernel@vger.kernel.org, linux@arm.linux.org.uk, keescook@chromium.org, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, corbet@lwn.net, dzickus@redhat.com, ebiederm@xmission.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, salyzyn@android.com, jeffv@google.com, nnk@google.com, dcashman <dcashman@google.com>

On Tue,  3 Nov 2015 10:10:03 -0800 Daniel Cashman <dcashman@android.com> wrote:

> ASLR currently only uses 8 bits to generate the random offset for the
> mmap base address on 32 bit architectures. This value was chosen to
> prevent a poorly chosen value from dividing the address space in such
> a way as to prevent large allocations. This may not be an issue on all
> platforms. Allow the specification of a minimum number of bits so that
> platforms desiring greater ASLR protection may determine where to place
> the trade-off.

Can we please include a very good description of the motivation for this
change?  What is inadequate about the current code, what value does the
enhancement have to our users, what real-world problems are being solved,
etc.

Because all we have at present is "greater ASLR protection", which doesn't
really tell anyone anything.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
