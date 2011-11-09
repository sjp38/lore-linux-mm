Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 29E386B0069
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 14:30:59 -0500 (EST)
Date: Wed, 9 Nov 2011 13:30:52 -0600 (CST)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [patch 1/2] slab: rename slab_break_gfp_order to
 slab_max_order
In-Reply-To: <CAOJsxLGOhW3tLTCZZw3VKoxd4Cg8ZN66ACj1vW3yQAFRenm3-A@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1111091330280.19817@router.home>
References: <alpine.DEB.2.00.1110182207500.5907@chino.kir.corp.google.com> <alpine.DEB.2.00.1111031440130.31612@chino.kir.corp.google.com> <CAOJsxLGOhW3tLTCZZw3VKoxd4Cg8ZN66ACj1vW3yQAFRenm3-A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 9 Nov 2011, Pekka Enberg wrote:

> The patches seem reasonable to me. Christoph?

Looks good and makes the two allocators to behave similarly.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
