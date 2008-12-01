Received: from localhost.localdomain ([96.237.168.40])
 by vms044.mailsrvcs.net (Sun Java System Messaging Server 6.2-6.01 (built Apr
 3 2006)) with ESMTPA id <0KB7002FSKO6RAC3@vms044.mailsrvcs.net> for
 linux-mm@kvack.org; Mon, 01 Dec 2008 11:31:19 -0600 (CST)
Date: Mon, 01 Dec 2008 12:31:16 -0500 (EST)
From: Len Brown <lenb@kernel.org>
Subject: Re: [patch][rfc] acpi: do not use kmem caches
In-reply-to: <20081201083128.GB2529@wotan.suse.de>
Message-id: <alpine.LFD.2.00.0812011134410.3197@localhost.localdomain>
MIME-version: 1.0
Content-type: TEXT/PLAIN; charset=US-ASCII
References: <20081201083128.GB2529@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-acpi@vger.kernel.org
List-ID: <linux-mm.kvack.org>



> What does everyone think about this patch?

Unexpected, Interesting.

We cut over to the native Linux allocator cache
from the ACPICA cache at a time when we had some
memory leaks, and it was important to be able
to walk up to a machine in the field that didn't
have any special build options and look in /proc
to find out what the different parts of our
sub-system were allocating.

I don't know the merits of SLAB vs. SLUB
or why Linux has two.  My local configs use SLAB
but I notice that recent Fedora kernels us SLUB.

>From an observability point of view, I guess I like SLAB
better because I can still see the 5 different ACPI caches
in /proc/slabinfo, while with SLUB I can see only one or two.

Note that these caches are used to interpret AML,
and how much AML you interpret depends a lot on the machine.
Some laptops will interpret AML all day long, while some
desktops and servers will run AML only at boot-time.

I guess my opinion is that I like the observatiblity we have now,
and that I'd need to see measurements showing that we're paying
too much for that observability.  I've also just now formed
an initial opinion on SLAB vs SLUB where I had none before.

thanks,
-Len

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
