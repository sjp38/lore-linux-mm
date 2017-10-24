Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 671C06B026F
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 05:40:44 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id p186so7785431wmd.11
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 02:40:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i67sor293967wmc.45.2017.10.24.02.40.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Oct 2017 02:40:43 -0700 (PDT)
Date: Tue, 24 Oct 2017 11:40:40 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/6] Boot-time switching between 4- and 5-level paging
 for 4.15, Part 1
Message-ID: <20171024094039.4lonzocjt5kras7m@gmail.com>
References: <20171003082754.no6ym45oirah53zp@node.shutemov.name>
 <20171017154241.f4zaxakfl7fcrdz5@node.shutemov.name>
 <20171020081853.lmnvaiydxhy5c63t@gmail.com>
 <20171020094152.skx5sh5ramq2a3vu@black.fi.intel.com>
 <20171020152346.f6tjybt7i5kzbhld@gmail.com>
 <20171020162349.3kwhdgv7qo45w4lh@node.shutemov.name>
 <20171023115658.geccs22o2t733np3@gmail.com>
 <20171023122159.wyztmsbgt5k2d4tb@node.shutemov.name>
 <20171023124014.mtklgmydspnvfcvg@gmail.com>
 <20171023124811.4i73242s5dotnn5k@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171023124811.4i73242s5dotnn5k@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill@shutemov.name> wrote:

> On Mon, Oct 23, 2017 at 02:40:14PM +0200, Ingo Molnar wrote:
> > 
> > * Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > 
> > > > Making a variable that 'looks' like a constant macro dynamic in a rare Kconfig 
> > > > scenario is asking for trouble.
> > > 
> > > We expect boot-time page mode switching to be enabled in kernel of next
> > > generation enterprise distros. It shoudn't be that rare.
> > 
> > My point remains even with not-so-rare Kconfig dependency.
> 
> I don't follow how introducing new variable that depends on Kconfig option
> would help with the situation.

A new, properly named variable or function (max_physmem_bits or 
max_physmem_bits()) that is not all uppercase would make it abundantly clear that 
it is not a constant but a runtime value.

> We would end up with inverse situation: people would use MAX_PHYSMEM_BITS
> where the new variable need to be used and we will in the same situation.

It should result in sub-optimal resource allocations worst-case, right?

We could also rename it to MAX_POSSIBLE_PHYSMEM_BITS to make it clear that the 
real number of bits can be lower.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
