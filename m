Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id AB3325F0003
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 12:13:19 -0400 (EDT)
Date: Wed, 3 Jun 2009 17:14:09 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Security fix for remapping of page 0 (was [PATCH] Change
 ZERO_SIZE_PTR to point at unmapped space)
Message-ID: <20090603171409.5c60422c@lxorguk.ukuu.org.uk>
In-Reply-To: <alpine.LFD.2.01.0906030827580.4880@localhost.localdomain>
References: <20090530192829.GK6535@oblivion.subreption.com>
	<alpine.LFD.2.01.0905301528540.3435@localhost.localdomain>
	<20090530230022.GO6535@oblivion.subreption.com>
	<alpine.LFD.2.01.0905301902010.3435@localhost.localdomain>
	<20090531022158.GA9033@oblivion.subreption.com>
	<alpine.DEB.1.10.0906021130410.23962@gentwo.org>
	<20090602203405.GC6701@oblivion.subreption.com>
	<alpine.DEB.1.10.0906031047390.15621@gentwo.org>
	<alpine.LFD.2.01.0906030800490.4880@localhost.localdomain>
	<alpine.DEB.1.10.0906031121030.15621@gentwo.org>
	<alpine.LFD.2.01.0906030827580.4880@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, "Larry H." <research@subreption.com>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

> It defaults to 64kB in at least the x86 defconfig files, but to 0 in the 
> Kconfig defaults. Also, for some reason it has a "depends on SECURITY", 
> which means that if you just default to the old-style unix security you'll 
> lose it.
> 
> So there are several ways to disable it by mistake. I don't know what 
> distros do.

Fedora at least uses SELinux to manage it. You need some kind of security
policy engine running as a few apps really need to map low space (mostly
for vm86)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
