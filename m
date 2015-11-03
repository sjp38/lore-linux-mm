Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 7D23382F64
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 17:40:14 -0500 (EST)
Received: by wicfx6 with SMTP id fx6so78748431wic.1
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 14:40:14 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id r7si30713616wmg.103.2015.11.03.14.40.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 03 Nov 2015 14:40:13 -0800 (PST)
Date: Tue, 3 Nov 2015 22:39:04 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v2 2/2] arm: mm: support ARCH_MMAP_RND_BITS.
Message-ID: <20151103223904.GG8644@n2100.arm.linux.org.uk>
References: <1446574204-15567-1-git-send-email-dcashman@android.com>
 <1446574204-15567-2-git-send-email-dcashman@android.com>
 <CAGXu5jKGzDD9WVQnMTT2EfupZtjpdcASUpx-3npLAB-FctLodA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jKGzDD9WVQnMTT2EfupZtjpdcASUpx-3npLAB-FctLodA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Daniel Cashman <dcashman@android.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Jonathan Corbet <corbet@lwn.net>, Don Zickus <dzickus@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Heinrich Schuchardt <xypron.glpk@gmx.de>, jpoimboe@redhat.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, n-horiguchi@ah.jp.nec.com, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Thomas Gleixner <tglx@linutronix.de>, David Rientjes <rientjes@google.com>, Linux-MM <linux-mm@kvack.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Mark Salyzyn <salyzyn@android.com>, Jeffrey Vander Stoep <jeffv@google.com>, Nick Kralevich <nnk@google.com>, dcashman <dcashman@google.com>

On Tue, Nov 03, 2015 at 11:19:44AM -0800, Kees Cook wrote:
> On Tue, Nov 3, 2015 at 10:10 AM, Daniel Cashman <dcashman@android.com> wrote:
> > From: dcashman <dcashman@google.com>
> >
> > arm: arch_mmap_rnd() uses a hard-code value of 8 to generate the
> > random offset for the mmap base address.  This value represents a
> > compromise between increased ASLR effectiveness and avoiding
> > address-space fragmentation. Replace it with a Kconfig option, which
> > is sensibly bounded, so that platform developers may choose where to
> > place this compromise. Keep 8 as the minimum acceptable value.
> >
> > Signed-off-by: Daniel Cashman <dcashman@google.com>
> 
> Acked-by: Kees Cook <keescook@chromium.org>
> 
> Russell, if you don't see any problems here, it might make sense not
> to put this through the ARM patch tracker since it depends on the 1/2,
> and I think x86 and arm64 (and possibly other arch) changes are coming
> too.

Yes, it looks sane, though I do wonder whether there should also be
a Kconfig option to allow archtectures to specify the default, instead
of the default always being the minimum randomisation.  I can see scope
to safely pushing our mmap randomness default to 12, especially on 3GB
setups, as we already have 11 bits of randomness on the sigpage and if
enabled, 13 bits on the heap.

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
