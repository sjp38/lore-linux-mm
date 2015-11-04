Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6D0CB82F64
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 20:28:37 -0500 (EST)
Received: by padhx2 with SMTP id hx2so27230005pad.1
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 17:28:37 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k5si46344982pbq.227.2015.11.03.17.28.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Nov 2015 17:28:36 -0800 (PST)
Date: Tue, 3 Nov 2015 17:31:56 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/2] mm: mmap: Add new /proc tunable for mmap_base
 ASLR.
Message-Id: <20151103173156.9ca17f52.akpm@linux-foundation.org>
In-Reply-To: <87k2pyppfk.fsf@x220.int.ebiederm.org>
References: <1446574204-15567-1-git-send-email-dcashman@android.com>
	<20151103160410.34bbebc805c17d2f41150a19@linux-foundation.org>
	<87k2pyppfk.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Daniel Cashman <dcashman@android.com>, linux-kernel@vger.kernel.org, linux@arm.linux.org.uk, keescook@chromium.org, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, corbet@lwn.net, dzickus@redhat.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, salyzyn@android.com, jeffv@google.com, nnk@google.com, dcashman <dcashman@google.com>

On Tue, 03 Nov 2015 18:40:31 -0600 ebiederm@xmission.com (Eric W. Biederman) wrote:

> Andrew Morton <akpm@linux-foundation.org> writes:
> 
> > On Tue,  3 Nov 2015 10:10:03 -0800 Daniel Cashman <dcashman@android.com> wrote:
> >
> >> ASLR currently only uses 8 bits to generate the random offset for the
> >> mmap base address on 32 bit architectures. This value was chosen to
> >> prevent a poorly chosen value from dividing the address space in such
> >> a way as to prevent large allocations. This may not be an issue on all
> >> platforms. Allow the specification of a minimum number of bits so that
> >> platforms desiring greater ASLR protection may determine where to place
> >> the trade-off.
> >
> > Can we please include a very good description of the motivation for this
> > change?  What is inadequate about the current code, what value does the
> > enhancement have to our users, what real-world problems are being solved,
> > etc.
> >
> > Because all we have at present is "greater ASLR protection", which doesn't
> > really tell anyone anything.
> 
> The description seemed clear to me.
> 
> More random bits, more entropy, more work needed to brute force.
> 
> 8 bits only requires 256 tries (or a 1 in 256) chance to brute force
> something.

Of course, but that's not really very useful.

> We have seen in the last couple of months on Android how only having 8 bits
> doesn't help much.

Now THAT is important.  What happened here and how well does the
proposed fix improve things?  How much longer will a brute-force attack
take to succeed, with a particular set of kernel parameters?  Is the
new duration considered to be sufficiently long and if not, are there
alternative fixes we should be looking at?

Stuff like this.

> Each additional bit doubles the protection (and unfortunately also
> increases fragmentation of the userspace address space).

OK, so the benefit comes with a cost and people who are configuring
systems (and the people who are reviewing this patchset!) need to
understand the tradeoffs.  Please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
