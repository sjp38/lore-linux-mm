Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 5CEFD6B002E
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 13:03:47 -0400 (EDT)
Date: Fri, 7 Oct 2011 12:03:43 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH 0/5] Slab objects identifiers
In-Reply-To: <4E8DD5B9.4060905@parallels.com>
Message-ID: <alpine.DEB.2.00.1110071159540.11042@router.home>
References: <4E8DD5B9.4060905@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, Glauber Costa <glommer@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 6 Oct 2011, Pavel Emelyanov wrote:

> While doing the checkpoint-restore in the userspace we need to determine
> whether various kernel objects (like mm_struct-s of file_struct-s) are shared
> between tasks and restore this state.
>
> The 2nd step can for now be solved by using respective CLONE_XXX flags and
> the unshare syscall, while there's currently no ways for solving the 1st one.
>
> One of the ways for checking whether two tasks share e.g. an mm_struct is to
> provide some mm_struct ID of a task to its proc file. The best from the
> performance point of view ID is the object address in the kernel, but showing
> them to the userspace is not good for performance reasons. Thus the ID should
> not be calculated based on the object address.

If two tasks share an mm_struct then the mm_struct pointer (task->mm) will
point to the same address. Objects are already uniquely identified by
their address. If you store the physical address with the object content
when transferring then you can verify that they share the mm_struct.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
