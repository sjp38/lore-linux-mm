Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 475996B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 06:20:53 -0400 (EDT)
Message-ID: <4E92C6FA.2050609@parallels.com>
Date: Mon, 10 Oct 2011 14:20:42 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] Slab objects identifiers
References: <4E8DD5B9.4060905@parallels.com> <alpine.DEB.2.00.1110071159540.11042@router.home>
In-Reply-To: <alpine.DEB.2.00.1110071159540.11042@router.home>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Glauber Costa <glommer@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>

On 10/07/2011 09:03 PM, Christoph Lameter wrote:
> On Thu, 6 Oct 2011, Pavel Emelyanov wrote:
> 
>> While doing the checkpoint-restore in the userspace we need to determine
>> whether various kernel objects (like mm_struct-s of file_struct-s) are shared
>> between tasks and restore this state.
>>
>> The 2nd step can for now be solved by using respective CLONE_XXX flags and
>> the unshare syscall, while there's currently no ways for solving the 1st one.
>>
>> One of the ways for checking whether two tasks share e.g. an mm_struct is to
>> provide some mm_struct ID of a task to its proc file. The best from the
>> performance point of view ID is the object address in the kernel, but showing
>> them to the userspace is not good for performance reasons. Thus the ID should
>> not be calculated based on the object address.
> 
> If two tasks share an mm_struct then the mm_struct pointer (task->mm) will
> point to the same address. Objects are already uniquely identified by
> their address.

Yes of course, but ...

> If you store the physical address with the object content
> when transferring then you can verify that they share the mm_struct.

... are we all OK with showing kernel addresses to the userspace? I thought the %pK
format was invented specially to handle such leaks.

If we are, then (as I said in the first letter) we should just show them and forget 
this set. If we're not - we should invent smth more straightforward and this set is 
an attempt for doing this.

Thanks,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
