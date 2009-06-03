Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2E3B76B00D1
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:39:38 -0400 (EDT)
Date: Wed, 3 Jun 2009 08:38:47 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Security fix for remapping of page 0 (was [PATCH] Change
 ZERO_SIZE_PTR to point at unmapped space)
In-Reply-To: <alpine.DEB.1.10.0906031121030.15621@gentwo.org>
Message-ID: <alpine.LFD.2.01.0906030827580.4880@localhost.localdomain>
References: <20090530192829.GK6535@oblivion.subreption.com> <alpine.LFD.2.01.0905301528540.3435@localhost.localdomain> <20090530230022.GO6535@oblivion.subreption.com> <alpine.LFD.2.01.0905301902010.3435@localhost.localdomain> <20090531022158.GA9033@oblivion.subreption.com>
 <alpine.DEB.1.10.0906021130410.23962@gentwo.org> <20090602203405.GC6701@oblivion.subreption.com> <alpine.DEB.1.10.0906031047390.15621@gentwo.org> <alpine.LFD.2.01.0906030800490.4880@localhost.localdomain> <alpine.DEB.1.10.0906031121030.15621@gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: "Larry H." <research@subreption.com>, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>



On Wed, 3 Jun 2009, Christoph Lameter wrote:

> On Wed, 3 Jun 2009, Linus Torvalds wrote:
> 
> > The point being that we do need to support mmap at zero. Not necessarily
> > universally, but it can't be some fixed "we don't allow that".
> 
> Hmmm... Depend on some capability? CAP_SYS_PTRACE may be something
> remotely related?

But as mentioned several times, we do have the system-wide setting in
'mmap_min_addr' (that then can be overridden by CAP_SYS_RAWIO, so in that 
sense a capability already exists).

It defaults to 64kB in at least the x86 defconfig files, but to 0 in the 
Kconfig defaults. Also, for some reason it has a "depends on SECURITY", 
which means that if you just default to the old-style unix security you'll 
lose it.

So there are several ways to disable it by mistake. I don't know what 
distros do.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
