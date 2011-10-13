Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id E55A16B002C
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 08:12:20 -0400 (EDT)
Received: by vcbfk1 with SMTP id fk1so1028908vcb.14
        for <linux-mm@kvack.org>; Thu, 13 Oct 2011 05:12:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4E96CAC3.3040402@parallels.com>
References: <4E8DD5B9.4060905@parallels.com>
	<alpine.DEB.2.00.1110071159540.11042@router.home>
	<4E92C6FA.2050609@parallels.com>
	<CAOJsxLGctbXuXNuCWukH6LayZkuKH=aTx1L7uk87gVbVOJ_MKg@mail.gmail.com>
	<4E96CAC3.3040402@parallels.com>
Date: Thu, 13 Oct 2011 15:12:17 +0300
Message-ID: <CAOJsxLFKPyzr48z8Z-c4za6tcZjjTgDXxSkr32aracfF7VrPEw@mail.gmail.com>
Subject: Re: [PATCH 0/5] Slab objects identifiers
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Christoph Lameter <cl@gentwo.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Glauber Costa <glommer@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Oct 13, 2011 at 2:25 PM, Pavel Emelyanov <xemul@parallels.com> wrote:
>>> ... are we all OK with showing kernel addresses to the userspace? I thought the %pK
>>> format was invented specially to handle such leaks.
>>
>> I don't think it's worth it to try to hide kernel addresses for
>> checkpoint/restart.
>
> We don't need to know anything about kernel internals for checkpoint-restart, that's
> why I said, that abstract identifiers are just fine.

OK.

>>> If we are, then (as I said in the first letter) we should just show them and forget
>>> this set. If we're not - we should invent smth more straightforward and this set is
>>> an attempt for doing this.
>>
>> Does this ID thing need to happen in the slab layer?
>
> Not necessarily, of course, but if we're going to show some identifier of an object
> we have 2 choices - either we generate this ID independently (with e.g. IDA), but
> this is slow, or we use some knowledge of an object as a bunch of bytes in memory.
> These slab IDs thing is an attempt to implement the 2nd approach.

Why is the first approach slow? I fully agree that unique IDs are probably the
way to go here but why don't you just add a new member to struct mm_struct and
initialize it in mm_alloc() and mm_dup()?

> The question I'm trying to answer with this is - do task A and task B have their mm
> shared or not? Showing an ID answers one. Maybe there exists another way, but I haven't
> invented it yet and decided to send this set out for discussion (the "release early"
> idiom). If slab maintainers say "no, we don't accept this at all ever", then of course
> I'll have to think further, but if the concept is suitable, but needs some refinement -
> let's do it.

Oh, I much appreciate that you sent this early. I'm not completely against doing
this in the slab layer but I need much more convincing. I expect most distros to
enable checkpoint/restart so this ID mechanism is going to be default
on for slab.

                            Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
