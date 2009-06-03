Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C0D966B0088
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 16:36:38 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D46D382CD19
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 16:51:26 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id j-L-YAYzUsk0 for <linux-mm@kvack.org>;
	Wed,  3 Jun 2009 16:51:26 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 7961382CD0F
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 16:51:20 -0400 (EDT)
Date: Wed, 3 Jun 2009 16:36:19 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Security fix for remapping of page 0 (was [PATCH] Change
 ZERO_SIZE_PTR to point at unmapped space)
In-Reply-To: <7e0fb38c0906031316n7aeed974xf15f8af5a3b04f63@mail.gmail.com>
Message-ID: <alpine.DEB.1.10.0906031635070.9368@gentwo.org>
References: <20090530230022.GO6535@oblivion.subreption.com>  <alpine.LFD.2.01.0906031109150.4880@localhost.localdomain>  <20090603183939.GC18561@oblivion.subreption.com>  <alpine.LFD.2.01.0906031142390.4880@localhost.localdomain>
 <alpine.LFD.2.01.0906031145460.4880@localhost.localdomain>  <alpine.DEB.1.10.0906031458250.9269@gentwo.org>  <7e0fb38c0906031214lf4a2ed2x688da299e8cb1034@mail.gmail.com>  <alpine.DEB.1.10.0906031537110.20254@gentwo.org>  <7e0fb38c0906031251h6844ea08y2dbfa09a7f46eb5f@mail.gmail.com>
  <alpine.DEB.1.10.0906031602250.20254@gentwo.org> <7e0fb38c0906031316n7aeed974xf15f8af5a3b04f63@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Eric Paris <eparis@parisplace.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "Larry H." <research@subreption.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, pageexec@freemail.hu, jmorris@namei.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 Jun 2009, Eric Paris wrote:

> > Thats easy to do but isnt it a bit weird now to configure mmap_min_addr?
>
> ??

The use of mmap_min_addr depends on the security configuration chose. The
security model may not check at all. But we can still configure the thing.

> > What about round_hint_to_min()?
>
> not sure what you mean....

We removed the CONFIG_SECURITY around code in there in the patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
