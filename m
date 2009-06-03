Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 70DF86B00E1
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 15:42:35 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id EB1C182CD28
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 15:57:19 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id pobt1zyS7U5u for <linux-mm@kvack.org>;
	Wed,  3 Jun 2009 15:57:19 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B1B6182CD2E
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 15:57:13 -0400 (EDT)
Date: Wed, 3 Jun 2009 15:42:13 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Security fix for remapping of page 0 (was [PATCH] Change
 ZERO_SIZE_PTR to point at unmapped space)
In-Reply-To: <7e0fb38c0906031214lf4a2ed2x688da299e8cb1034@mail.gmail.com>
Message-ID: <alpine.DEB.1.10.0906031537110.20254@gentwo.org>
References: <20090530230022.GO6535@oblivion.subreption.com>  <alpine.DEB.1.10.0906031047390.15621@gentwo.org>  <20090603182949.5328d411@lxorguk.ukuu.org.uk>  <alpine.LFD.2.01.0906031032390.4880@localhost.localdomain>  <20090603180037.GB18561@oblivion.subreption.com>
  <alpine.LFD.2.01.0906031109150.4880@localhost.localdomain>  <20090603183939.GC18561@oblivion.subreption.com>  <alpine.LFD.2.01.0906031142390.4880@localhost.localdomain>  <alpine.LFD.2.01.0906031145460.4880@localhost.localdomain>  <alpine.DEB.1.10.0906031458250.9269@gentwo.org>
 <7e0fb38c0906031214lf4a2ed2x688da299e8cb1034@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Eric Paris <eparis@parisplace.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "Larry H." <research@subreption.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

On Wed, 3 Jun 2009, Eric Paris wrote:

> NAK  with SELinux on you now need both the SELinux mmap_zero
> permission and the CAP_SYS_RAWIO permission.  Previously you only
> needed one or the other, depending on which was the predominant
> LSM.....

CAP_SYS_RAWIO is checked so you only need to check for mmap_zero in
SELinux.

> Even if you want to argue that I have to take CAP_SYS_RAWIO in the
> SELinux case what about all the other places?  do_mremap?  do_brk?
> expand_downwards?

brk(0) would free up all the code? The others could be added.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
