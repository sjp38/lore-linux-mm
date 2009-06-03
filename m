Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9DEF35F0003
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 12:20:53 -0400 (EDT)
Date: Wed, 3 Jun 2009 09:19:34 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Security fix for remapping of page 0 (was [PATCH] Change
 ZERO_SIZE_PTR to point at unmapped space)
In-Reply-To: <20090603171409.5c60422c@lxorguk.ukuu.org.uk>
Message-ID: <alpine.LFD.2.01.0906030918490.4880@localhost.localdomain>
References: <20090530192829.GK6535@oblivion.subreption.com> <alpine.LFD.2.01.0905301528540.3435@localhost.localdomain> <20090530230022.GO6535@oblivion.subreption.com> <alpine.LFD.2.01.0905301902010.3435@localhost.localdomain> <20090531022158.GA9033@oblivion.subreption.com>
 <alpine.DEB.1.10.0906021130410.23962@gentwo.org> <20090602203405.GC6701@oblivion.subreption.com> <alpine.DEB.1.10.0906031047390.15621@gentwo.org> <alpine.LFD.2.01.0906030800490.4880@localhost.localdomain> <alpine.DEB.1.10.0906031121030.15621@gentwo.org>
 <alpine.LFD.2.01.0906030827580.4880@localhost.localdomain> <20090603171409.5c60422c@lxorguk.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Christoph Lameter <cl@linux-foundation.org>, "Larry H." <research@subreption.com>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>



On Wed, 3 Jun 2009, Alan Cox wrote:
> 
> Fedora at least uses SELinux to manage it. You need some kind of security
> policy engine running as a few apps really need to map low space (mostly
> for vm86)

Well, vm86 isn't even an issue on x86-64, so it's arguable that at least a 
few cases could very easily just make it more static and obvious.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
