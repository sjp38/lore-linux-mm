Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E474E6B002C
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 03:12:22 -0400 (EDT)
Received: by vws16 with SMTP id 16so1715635vws.14
        for <linux-mm@kvack.org>; Thu, 13 Oct 2011 00:12:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4E92C6FA.2050609@parallels.com>
References: <4E8DD5B9.4060905@parallels.com>
	<alpine.DEB.2.00.1110071159540.11042@router.home>
	<4E92C6FA.2050609@parallels.com>
Date: Thu, 13 Oct 2011 10:12:20 +0300
Message-ID: <CAOJsxLGctbXuXNuCWukH6LayZkuKH=aTx1L7uk87gVbVOJ_MKg@mail.gmail.com>
Subject: Re: [PATCH 0/5] Slab objects identifiers
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Christoph Lameter <cl@gentwo.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Glauber Costa <glommer@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Oct 10, 2011 at 1:20 PM, Pavel Emelyanov <xemul@parallels.com> wrote:
>> If two tasks share an mm_struct then the mm_struct pointer (task->mm) will
>> point to the same address. Objects are already uniquely identified by
>> their address.
>
> Yes of course, but ...
>
>> If you store the physical address with the object content
>> when transferring then you can verify that they share the mm_struct.
>
> ... are we all OK with showing kernel addresses to the userspace? I thought the %pK
> format was invented specially to handle such leaks.

I don't think it's worth it to try to hide kernel addresses for
checkpoint/restart.

> If we are, then (as I said in the first letter) we should just show them and forget
> this set. If we're not - we should invent smth more straightforward and this set is
> an attempt for doing this.

Does this ID thing need to happen in the slab layer?

                              Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
