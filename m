Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A091A6B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 11:24:40 -0400 (EDT)
Date: Mon, 10 Oct 2011 10:24:36 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH 0/5] Slab objects identifiers
In-Reply-To: <4E92C6FA.2050609@parallels.com>
Message-ID: <alpine.DEB.2.00.1110101022220.16264@router.home>
References: <4E8DD5B9.4060905@parallels.com> <alpine.DEB.2.00.1110071159540.11042@router.home> <4E92C6FA.2050609@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Glauber Costa <glommer@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 10 Oct 2011, Pavel Emelyanov wrote:

> > If you store the physical address with the object content
> > when transferring then you can verify that they share the mm_struct.
>
> ... are we all OK with showing kernel addresses to the userspace? I thought the %pK
> format was invented specially to handle such leaks.

Not in general but I think for process migration we are fine with the
handling of the addresses. Doesnt process migration require rooot anyways?

Adding additional metadata to each slab or object is certainly not
acceptable because it slows down operations for everyone.

> If we are, then (as I said in the first letter) we should just show them and forget
> this set. If we're not - we should invent smth more straightforward and this set is
> an attempt for doing this.

Well one solution is to show the addresses only to members of a specific
group or only to root.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
