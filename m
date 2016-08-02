Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 50D836B0005
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 23:35:17 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id u142so340491382oia.2
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 20:35:17 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id 37si812872ios.241.2016.08.01.20.35.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Aug 2016 20:35:16 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [kernel-hardening] Re: [PATCH v2 1/7] random: Simplify API for random address requests
In-Reply-To: <20160801231723.GG4541@io.lakedaemon.net>
References: <20160728204730.27453-1-jason@lakedaemon.net> <20160730154244.403-1-jason@lakedaemon.net> <20160730154244.403-2-jason@lakedaemon.net> <CAGXu5jL3ZtjbhOYujVUpBuDttPjetaz8rSY_hNK13r6OtR4sFQ@mail.gmail.com> <20160731205632.GY4541@io.lakedaemon.net> <CAGXu5jJVM=LXA10z06zVcFDSbf8s72HcOPRc_nUeuU7W=-3JWg@mail.gmail.com> <20160801231723.GG4541@io.lakedaemon.net>
Date: Tue, 02 Aug 2016 13:35:13 +1000
Message-ID: <878twfonbi.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Cooper <jason@lakedaemon.net>, Kees Cook <keescook@chromium.org>
Cc: "Roberts, William C" <william.c.roberts@intel.com>, Yann Droneaud <ydroneaud@opteya.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Arnd Bergmann <arnd@arndb.de>, Greg KH <gregkh@linuxfoundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Nick Kralevich <nnk@google.com>, Jeffrey Vander Stoep <jeffv@google.com>, Daniel Cashman <dcashman@android.com>

Jason Cooper <jason@lakedaemon.net> writes:
> On Mon, Aug 01, 2016 at 12:47:59PM -0700, Kees Cook wrote:
>> On Sun, Jul 31, 2016 at 1:56 PM, Jason Cooper <jason@lakedaemon.net> wrote:
>> 
>> I have no new call sites in mind, but it seems safe to add a BUG_ON to
>> verify we don't gain callers that don't follow the correct
>> expectations. (Or maybe WARN and return start.)
>
> No, I think BUG_ON is appropriate.  afaict, the only time this will be
> encountered is during the development process.

Unless it's not.

Why crash someone's system when you could just page align the value
you're given?

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
