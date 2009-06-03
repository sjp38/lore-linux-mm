Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9A5336B005C
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 17:21:26 -0400 (EDT)
Date: Wed, 3 Jun 2009 14:20:57 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Security fix for remapping of page 0 (was [PATCH] Change
 ZERO_SIZE_PTR to point at unmapped space)
In-Reply-To: <alpine.DEB.1.10.0906031602250.20254@gentwo.org>
Message-ID: <alpine.LFD.2.01.0906031414570.4880@localhost.localdomain>
References: <20090530230022.GO6535@oblivion.subreption.com>  <alpine.LFD.2.01.0906031032390.4880@localhost.localdomain>  <20090603180037.GB18561@oblivion.subreption.com>  <alpine.LFD.2.01.0906031109150.4880@localhost.localdomain>  <20090603183939.GC18561@oblivion.subreption.com>
  <alpine.LFD.2.01.0906031142390.4880@localhost.localdomain>  <alpine.LFD.2.01.0906031145460.4880@localhost.localdomain>  <alpine.DEB.1.10.0906031458250.9269@gentwo.org>  <7e0fb38c0906031214lf4a2ed2x688da299e8cb1034@mail.gmail.com>
 <alpine.DEB.1.10.0906031537110.20254@gentwo.org> <7e0fb38c0906031251h6844ea08y2dbfa09a7f46eb5f@mail.gmail.com> <alpine.DEB.1.10.0906031602250.20254@gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Eric Paris <eparis@parisplace.org>, "Larry H." <research@subreption.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>



On Wed, 3 Jun 2009, Christoph Lameter wrote:
> 
> Use mmap_min_addr indepedently of security models

Looks ok by me. As mentioned, it would be nice if the coherency with the 
'capabilities' security module was something inherent to the code, but 
this looks like a sane minimal patch.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
