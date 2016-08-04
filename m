Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id CCC786B0253
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 20:19:50 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id le9so5935088pab.0
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 17:19:50 -0700 (PDT)
Received: from pmta2.delivery5.ore.mailhop.org (pmta2.delivery5.ore.mailhop.org. [54.186.218.12])
        by mx.google.com with ESMTPS id i129si11373828pfc.174.2016.08.03.17.19.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Aug 2016 17:19:49 -0700 (PDT)
Date: Thu, 4 Aug 2016 00:19:43 +0000
From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH v3 7/7] random: Remove unused randomize_range()
Message-ID: <20160804001943.GS4541@io.lakedaemon.net>
References: <20160728204730.27453-1-jason@lakedaemon.net>
 <20160803233913.32511-1-jason@lakedaemon.net>
 <20160803233913.32511-8-jason@lakedaemon.net>
 <20160803164810.6eff457c210a4da46782b45f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160803164810.6eff457c210a4da46782b45f@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kees Cook <keescook@chromium.org>, Michael Ellerman <mpe@ellerman.id.au>, "Roberts, William C" <william.c.roberts@intel.com>, Yann Droneaud <ydroneaud@opteya.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kernel-hardening <kernel-hardening@lists.openwall.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Theodore Ts'o <tytso@mit.edu>, Arnd Bergmann <arnd@arndb.de>, gregkh@linuxfoundation.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>, benh@kernel.crashing.org, paulus@samba.org, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, viro@zeniv.linux.org.uk, Nick Kralevich <nnk@google.com>, Jeffrey Vander Stoep <jeffv@google.com>, Daniel Cashman <dcashman@android.com>

On Wed, Aug 03, 2016 at 04:48:10PM -0700, Andrew Morton wrote:
> On Wed,  3 Aug 2016 23:39:13 +0000 Jason Cooper <jason@lakedaemon.net> wrote:
> 
> > All call sites for randomize_range have been updated to use the much
> > simpler and more robust randomize_addr.  Remove the now unnecessary
> > code.
> 
> "randomize_page'.

Doh!

> I think I'll grab these patches, see if anybody emits any squeaks.

Thanks, Andrew!

thx,

Jason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
