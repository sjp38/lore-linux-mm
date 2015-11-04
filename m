Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 4FCBB6B0253
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 19:49:29 -0500 (EST)
Received: by pasz6 with SMTP id z6so34589740pas.2
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 16:49:29 -0800 (PST)
Received: from out02.mta.xmission.com (out02.mta.xmission.com. [166.70.13.232])
        by mx.google.com with ESMTPS id bx3si46189205pbc.35.2015.11.03.16.49.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 03 Nov 2015 16:49:28 -0800 (PST)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <1446574204-15567-1-git-send-email-dcashman@android.com>
	<20151103160410.34bbebc805c17d2f41150a19@linux-foundation.org>
Date: Tue, 03 Nov 2015 18:40:31 -0600
In-Reply-To: <20151103160410.34bbebc805c17d2f41150a19@linux-foundation.org>
	(Andrew Morton's message of "Tue, 3 Nov 2015 16:04:10 -0800")
Message-ID: <87k2pyppfk.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [PATCH v2 1/2] mm: mmap: Add new /proc tunable for mmap_base ASLR.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daniel Cashman <dcashman@android.com>, linux-kernel@vger.kernel.org, linux@arm.linux.org.uk, keescook@chromium.org, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, corbet@lwn.net, dzickus@redhat.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, salyzyn@android.com, jeffv@google.com, nnk@google.com, dcashman <dcashman@google.com>

Andrew Morton <akpm@linux-foundation.org> writes:

> On Tue,  3 Nov 2015 10:10:03 -0800 Daniel Cashman <dcashman@android.com> wrote:
>
>> ASLR currently only uses 8 bits to generate the random offset for the
>> mmap base address on 32 bit architectures. This value was chosen to
>> prevent a poorly chosen value from dividing the address space in such
>> a way as to prevent large allocations. This may not be an issue on all
>> platforms. Allow the specification of a minimum number of bits so that
>> platforms desiring greater ASLR protection may determine where to place
>> the trade-off.
>
> Can we please include a very good description of the motivation for this
> change?  What is inadequate about the current code, what value does the
> enhancement have to our users, what real-world problems are being solved,
> etc.
>
> Because all we have at present is "greater ASLR protection", which doesn't
> really tell anyone anything.

The description seemed clear to me.

More random bits, more entropy, more work needed to brute force.

8 bits only requires 256 tries (or a 1 in 256) chance to brute force
something.

We have seen in the last couple of months on Android how only having 8 bits
doesn't help much.

Each additional bit doubles the protection (and unfortunately also
increases fragmentation of the userspace address space).

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
