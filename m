Received: from obelix.hrz.tu-chemnitz.de (obelix.hrz.tu-chemnitz.de [134.109.132.55])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA11744
	for <linux-mm@kvack.org>; Thu, 8 Apr 1999 18:02:06 -0400
Date: Fri, 9 Apr 1999 00:00:22 +0200 (CEST)
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: persistent heap design advice
In-Reply-To: <013f01be81e4$88f07860$0201a8c0@edison.inter-tax.com>
Message-ID: <Pine.LNX.4.10.9904082343010.22787-100000@nightmaster.csn.tu-chemnitz.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Keith Morgan <kmorgan@inter-tax.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 8 Apr 1999, Keith Morgan wrote:

> -If not, are there kernel/vm hooks that can be used to create it?
> kernel)

Look at 'include/linux/mm.h'.

There you can find 'struct vm_operations_struct', which provides
all the possible (and needed) hooks into the Linux-VMM.

Just take the implementation of 'mm/filemap.c' and modify it to
support your scheme of caching.

The only thing left to do is a SYSCALL-API-function. But this
isn't a real problem, is it?

Regards

Ingo Oeser
-- 
Feel the power of the penguin - run linux@your.pc
<esc>:x

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
