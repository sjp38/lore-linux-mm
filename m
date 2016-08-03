Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CE8F7828E1
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 19:48:12 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h186so424087756pfg.2
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 16:48:12 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ul1si11213168pac.252.2016.08.03.16.48.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Aug 2016 16:48:12 -0700 (PDT)
Date: Wed, 3 Aug 2016 16:48:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 7/7] random: Remove unused randomize_range()
Message-Id: <20160803164810.6eff457c210a4da46782b45f@linux-foundation.org>
In-Reply-To: <20160803233913.32511-8-jason@lakedaemon.net>
References: <20160728204730.27453-1-jason@lakedaemon.net>
	<20160803233913.32511-1-jason@lakedaemon.net>
	<20160803233913.32511-8-jason@lakedaemon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Cooper <jason@lakedaemon.net>
Cc: Kees Cook <keescook@chromium.org>, Michael Ellerman <mpe@ellerman.id.au>, "Roberts, William C" <william.c.roberts@intel.com>, Yann Droneaud <ydroneaud@opteya.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kernel-hardening <kernel-hardening@lists.openwall.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Theodore Ts'o <tytso@mit.edu>, Arnd Bergmann <arnd@arndb.de>, gregkh@linuxfoundation.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>, benh@kernel.crashing.org, paulus@samba.org, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, viro@zeniv.linux.org.uk, Nick Kralevich <nnk@google.com>, Jeffrey Vander Stoep <jeffv@google.com>, Daniel Cashman <dcashman@android.com>

On Wed,  3 Aug 2016 23:39:13 +0000 Jason Cooper <jason@lakedaemon.net> wrote:

> All call sites for randomize_range have been updated to use the much
> simpler and more robust randomize_addr.  Remove the now unnecessary
> code.

"randomize_page'.

I think I'll grab these patches, see if anybody emits any squeaks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
