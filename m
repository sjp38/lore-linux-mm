Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CBC2F6B00BE
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:23:55 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 02A0E82CC49
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:38:43 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id l3X9mfHgl0H4 for <linux-mm@kvack.org>;
	Wed,  3 Jun 2009 11:38:42 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D091082CC82
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:38:36 -0400 (EDT)
Date: Wed, 3 Jun 2009 11:23:47 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Security fix for remapping of page 0 (was [PATCH] Change
 ZERO_SIZE_PTR to point at unmapped space)
In-Reply-To: <alpine.LFD.2.01.0906030800490.4880@localhost.localdomain>
Message-ID: <alpine.DEB.1.10.0906031121030.15621@gentwo.org>
References: <20090530192829.GK6535@oblivion.subreption.com> <alpine.LFD.2.01.0905301528540.3435@localhost.localdomain> <20090530230022.GO6535@oblivion.subreption.com> <alpine.LFD.2.01.0905301902010.3435@localhost.localdomain> <20090531022158.GA9033@oblivion.subreption.com>
 <alpine.DEB.1.10.0906021130410.23962@gentwo.org> <20090602203405.GC6701@oblivion.subreption.com> <alpine.DEB.1.10.0906031047390.15621@gentwo.org> <alpine.LFD.2.01.0906030800490.4880@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Larry H." <research@subreption.com>, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

On Wed, 3 Jun 2009, Linus Torvalds wrote:

> The point being that we do need to support mmap at zero. Not necessarily
> universally, but it can't be some fixed "we don't allow that".

Hmmm... Depend on some capability? CAP_SYS_PTRACE may be something
remotely related?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
