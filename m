Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BA6556B00B7
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 14:13:11 -0400 (EDT)
Date: Wed, 3 Jun 2009 11:12:21 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Security fix for remapping of page 0 (was [PATCH] Change
 ZERO_SIZE_PTR to point at unmapped space)
In-Reply-To: <20090603180037.GB18561@oblivion.subreption.com>
Message-ID: <alpine.LFD.2.01.0906031109150.4880@localhost.localdomain>
References: <20090530192829.GK6535@oblivion.subreption.com> <alpine.LFD.2.01.0905301528540.3435@localhost.localdomain> <20090530230022.GO6535@oblivion.subreption.com> <alpine.LFD.2.01.0905301902010.3435@localhost.localdomain> <20090531022158.GA9033@oblivion.subreption.com>
 <alpine.DEB.1.10.0906021130410.23962@gentwo.org> <20090602203405.GC6701@oblivion.subreption.com> <alpine.DEB.1.10.0906031047390.15621@gentwo.org> <20090603182949.5328d411@lxorguk.ukuu.org.uk> <alpine.LFD.2.01.0906031032390.4880@localhost.localdomain>
 <20090603180037.GB18561@oblivion.subreption.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>



On Wed, 3 Jun 2009, Larry H. wrote:
> 
> Are you saying that a kernel exploit can't be leveraged by means of
> runtime code injection for example?

No. I'm sayng that sane people don't get hung up about every little 
possibility.

Why are security people always so damn black-and-white? In most other 
areas, such people are called "crazy" or "stupid", but the security people 
seem to call them "normal".

The fact, the NULL pointer attack is neither easy nor common. It's 
perfectly reasonable to say "we'll allow mmap at virtual address zero".

Disallowing NULL pointer mmap's is one small tool in your toolchest, and 
not at all all-consumingly important or fundamental. It's just one more 
detail.

Get over it. Don't expect everybody to be as extremist as you apparently 
are.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
