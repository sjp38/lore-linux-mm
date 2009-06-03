Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B66325F0019
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 13:28:54 -0400 (EDT)
Date: Wed, 3 Jun 2009 18:29:49 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Security fix for remapping of page 0 (was [PATCH] Change
 ZERO_SIZE_PTR to point at unmapped space)
Message-ID: <20090603182949.5328d411@lxorguk.ukuu.org.uk>
In-Reply-To: <alpine.DEB.1.10.0906031047390.15621@gentwo.org>
References: <20090530192829.GK6535@oblivion.subreption.com>
	<alpine.LFD.2.01.0905301528540.3435@localhost.localdomain>
	<20090530230022.GO6535@oblivion.subreption.com>
	<alpine.LFD.2.01.0905301902010.3435@localhost.localdomain>
	<20090531022158.GA9033@oblivion.subreption.com>
	<alpine.DEB.1.10.0906021130410.23962@gentwo.org>
	<20090602203405.GC6701@oblivion.subreption.com>
	<alpine.DEB.1.10.0906031047390.15621@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: "Larry H." <research@subreption.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

> Ok. So what we need to do is stop this toying around with remapping of
> page 0. The following patch contains a fix and a test program that
> demonstrates the issue.

NAK - you've now broken half a dozen apps.

One way you could approach this would be to write a security module for
non SELINUX users - one that did one thing alone - decide whether the app
being run was permitted to map the low 64K perhaps by checking the
security label on the file.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
