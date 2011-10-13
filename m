Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id BEFC76B002C
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 07:26:09 -0400 (EDT)
Message-ID: <4E96CAC3.3040402@parallels.com>
Date: Thu, 13 Oct 2011 15:25:55 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] Slab objects identifiers
References: <4E8DD5B9.4060905@parallels.com>	<alpine.DEB.2.00.1110071159540.11042@router.home>	<4E92C6FA.2050609@parallels.com> <CAOJsxLGctbXuXNuCWukH6LayZkuKH=aTx1L7uk87gVbVOJ_MKg@mail.gmail.com>
In-Reply-To: <CAOJsxLGctbXuXNuCWukH6LayZkuKH=aTx1L7uk87gVbVOJ_MKg@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <cl@gentwo.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Glauber Costa <glommer@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>

On 10/13/2011 11:12 AM, Pekka Enberg wrote:
> On Mon, Oct 10, 2011 at 1:20 PM, Pavel Emelyanov <xemul@parallels.com> wrote:
>>> If two tasks share an mm_struct then the mm_struct pointer (task->mm) will
>>> point to the same address. Objects are already uniquely identified by
>>> their address.
>>
>> Yes of course, but ...
>>
>>> If you store the physical address with the object content
>>> when transferring then you can verify that they share the mm_struct.
>>
>> ... are we all OK with showing kernel addresses to the userspace? I thought the %pK
>> format was invented specially to handle such leaks.
> 
> I don't think it's worth it to try to hide kernel addresses for
> checkpoint/restart.

We don't need to know anything about kernel internals for checkpoint-restart, that's
why I said, that abstract identifiers are just fine.

>> If we are, then (as I said in the first letter) we should just show them and forget
>> this set. If we're not - we should invent smth more straightforward and this set is
>> an attempt for doing this.
> 
> Does this ID thing need to happen in the slab layer?

Not necessarily, of course, but if we're going to show some identifier of an object
we have 2 choices - either we generate this ID independently (with e.g. IDA), but
this is slow, or we use some knowledge of an object as a bunch of bytes in memory.
These slab IDs thing is an attempt to implement the 2nd approach.


The question I'm trying to answer with this is - do task A and task B have their mm
shared or not? Showing an ID answers one. Maybe there exists another way, but I haven't
invented it yet and decided to send this set out for discussion (the "release early"
idiom). If slab maintainers say "no, we don't accept this at all ever", then of course
I'll have to think further, but if the concept is suitable, but needs some refinement - 
let's do it.

>                               Pekka
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
