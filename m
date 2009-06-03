Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 949D95F0019
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 13:58:56 -0400 (EDT)
Date: Wed, 3 Jun 2009 11:00:37 -0700
From: "Larry H." <research@subreption.com>
Subject: Re: Security fix for remapping of page 0 (was [PATCH] Change
	ZERO_SIZE_PTR to point at unmapped space)
Message-ID: <20090603180037.GB18561@oblivion.subreption.com>
References: <20090530192829.GK6535@oblivion.subreption.com> <alpine.LFD.2.01.0905301528540.3435@localhost.localdomain> <20090530230022.GO6535@oblivion.subreption.com> <alpine.LFD.2.01.0905301902010.3435@localhost.localdomain> <20090531022158.GA9033@oblivion.subreption.com> <alpine.DEB.1.10.0906021130410.23962@gentwo.org> <20090602203405.GC6701@oblivion.subreption.com> <alpine.DEB.1.10.0906031047390.15621@gentwo.org> <20090603182949.5328d411@lxorguk.ukuu.org.uk> <alpine.LFD.2.01.0906031032390.4880@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.01.0906031032390.4880@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

On 10:35 Wed 03 Jun     , Linus Torvalds wrote:
> 
> 
> On Wed, 3 Jun 2009, Alan Cox wrote:
> >
> > One way you could approach this would be to write a security module for
> > non SELINUX users - one that did one thing alone - decide whether the app
> > being run was permitted to map the low 64K perhaps by checking the
> > security label on the file.
> 
> Unnecessary. I really think that 99% of all people are perfectly fine with 
> just the "mmap_min_addr" rule, and no more.
> 
> The rest could just use SElinux or set it to zero. It's not like allowing 
> mmap's at NULL is a huge problem. Sure, it allows a certain kind of attack 
> vector, but it's by no means an easy or common one - you need to already 
> have gotten fairly good local access to take advantage of it.

Are you saying that a kernel exploit can't be leveraged by means of
runtime code injection for example? By exploiting a completely
unprivileged daemon remotely? It's not 1990 anymore. People compromise
your system from memory, disk doesn't get to see the ladies poledancing
your kernel $pc.

Not easy? You should definitely ask the people who wrote those exploits what
kind of difficulty they encountered writing them. It goes like this:

	1) Have kernel flaw which leads to function ptr call from NULL
	or offset from NULL. Or can overwrite one. Or corrupt a kernel
	object. Not challenging.

	2) In your userland process, map NULL. Insert fake structures
	with proper pointers to your shellcode of choice. Not
	challenging.

	3) Run the exploit.

Not common? Compile a list of past reported NULL ptr deference oopses
from the Red Hat bugzilla, kernel bugzilla or the LKML. Check how many
of those could be triggered via normal syscall/unprivileged code paths.

You didn't answer my follow-up to your initial mail arguing the patch
was of no use, where I described a realistic scenario. Does that mean
you agree with it? If not, I would like to hear your opinion.

	Larry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
