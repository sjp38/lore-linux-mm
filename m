Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id C89896B0253
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 14:43:03 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id p85so119317567lfg.3
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 11:43:03 -0700 (PDT)
Received: from outbound1.eu.mailhop.org (outbound1.eu.mailhop.org. [52.28.251.132])
        by mx.google.com with ESMTPS id tm3si9373364wjc.108.2016.08.03.11.43.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Aug 2016 11:43:02 -0700 (PDT)
Date: Wed, 3 Aug 2016 18:42:47 +0000
From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [kernel-hardening] Re: [PATCH v2 1/7] random: Simplify API for
 random address requests
Message-ID: <20160803184247.GR4541@io.lakedaemon.net>
References: <20160728204730.27453-1-jason@lakedaemon.net>
 <20160730154244.403-1-jason@lakedaemon.net>
 <20160730154244.403-2-jason@lakedaemon.net>
 <CAGXu5jL3ZtjbhOYujVUpBuDttPjetaz8rSY_hNK13r6OtR4sFQ@mail.gmail.com>
 <20160731205632.GY4541@io.lakedaemon.net>
 <CAGXu5jJVM=LXA10z06zVcFDSbf8s72HcOPRc_nUeuU7W=-3JWg@mail.gmail.com>
 <20160801231723.GG4541@io.lakedaemon.net>
 <878twfonbi.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <878twfonbi.fsf@concordia.ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Kees Cook <keescook@chromium.org>, "Roberts, William C" <william.c.roberts@intel.com>, Yann Droneaud <ydroneaud@opteya.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Arnd Bergmann <arnd@arndb.de>, Greg KH <gregkh@linuxfoundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Nick Kralevich <nnk@google.com>, Jeffrey Vander Stoep <jeffv@google.com>, Daniel Cashman <dcashman@android.com>

On Tue, Aug 02, 2016 at 01:35:13PM +1000, Michael Ellerman wrote:
> Jason Cooper <jason@lakedaemon.net> writes:
> > On Mon, Aug 01, 2016 at 12:47:59PM -0700, Kees Cook wrote:
> >> On Sun, Jul 31, 2016 at 1:56 PM, Jason Cooper <jason@lakedaemon.net> wrote:
> >> 
> >> I have no new call sites in mind, but it seems safe to add a BUG_ON to
> >> verify we don't gain callers that don't follow the correct
> >> expectations. (Or maybe WARN and return start.)
> >
> > No, I think BUG_ON is appropriate.  afaict, the only time this will be
> > encountered is during the development process.
> 
> Unless it's not.
> 
> Why crash someone's system when you could just page align the value
> you're given?

Ack, v3 on it's way.

thx,

Jason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
