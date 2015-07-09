Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id C880A6B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 17:21:57 -0400 (EDT)
Received: by igrv9 with SMTP id v9so203245240igr.1
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 14:21:57 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b142si6382350ioe.42.2015.07.09.14.21.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 14:21:57 -0700 (PDT)
Date: Thu, 9 Jul 2015 14:21:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mm: new mm hook framework
Message-Id: <20150709142155.f749ec0dd92b0a4ee0ba8d32@linux-foundation.org>
In-Reply-To: <558BBF05.1050703@linux.vnet.ibm.com>
References: <20150625040814.6C421660F7B@gitolite.kernel.org>
	<CAMuHMdUG3CbPGvTuPF_JO4JL1C6aqPpLwuZjfixF1zU117Vjfw@mail.gmail.com>
	<558BBF05.1050703@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux-Arch <linux-arch@vger.kernel.org>

On Thu, 25 Jun 2015 10:42:45 +0200 Laurent Dufour <ldufour@linux.vnet.ibm.com> wrote:

> > IMHO this screams for the generic version in include/asm-generic/,
> > and "generic-y += mm-arch-hooks.h" in arch/*/include/asm/Kbuild/.
> 
> I do like your proposal which avoid creating too many *empty* files.
> Since Andrew suggested the way I did the current patch, I'd appreciate
> his feedback too.

But this infrastructure works the other way.  If an architecture wants
a private implementation of arch_remap(), it adds a definition into
arch/XXX/include/asm/mm-arch-hooks.h and does #define arch_remap arch_remap.

If the architecture is OK with the default implementation of
arch_remap(), it does nothing at all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
