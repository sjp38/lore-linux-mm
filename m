Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 0B6556B004F
	for <linux-mm@kvack.org>; Sun, 31 May 2009 06:32:54 -0400 (EDT)
Date: Sun, 31 May 2009 11:34:04 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [patch 5/5] Apply the PG_sensitive flag to the CryptoAPI
 subsystem
Message-ID: <20090531113404.5051114d@lxorguk.ukuu.org.uk>
In-Reply-To: <4A225887.21178.1C8AE762@pageexec.freemail.hu>
References: <20090520190519.GE10756@oblivion.subreption.com>
	<20090530180540.GE20013@elte.hu>
	<4A225887.21178.1C8AE762@pageexec.freemail.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: pageexec@freemail.hu
Cc: "Larry H." <research@subreption.com>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, linux-crypto@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

> > Also, there's no discussion about long-lived threads keeping 
> > sensitive information in there kernel stack indefinitely.
> 
> kernel stack clearing isn't hard to do, just do it on every syscall exit
> and in the infinite loop for kernel threads.

Actually that is probably not as important. In most cases you would be
leaking data between syscalls made by the same thread. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
