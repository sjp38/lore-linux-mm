Message-ID: <4544C709.6070305@google.com>
Date: Sun, 29 Oct 2006 07:21:45 -0800
From: "Martin J. Bligh" <mbligh@google.com>
MIME-Version: 1.0
Subject: Re: Slab panic on 2.6.19-rc3-git5 (-git4 was OK)
References: <20061029124655.7014.qmail@web32408.mail.mud.yahoo.com>
In-Reply-To: <20061029124655.7014.qmail@web32408.mail.mud.yahoo.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Giridhar Pemmasani <pgiri@yahoo.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Whitcroft <apw@shadowen.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

>> I only skimmed through this briefly but it looks like due to
>> 52fd24ca1db3a741f144bbc229beefe044202cac __get_vm_area_node is passing
>> GFP_HIGHMEM to kmem_cache_alloc_node which is a no-no.
> 
> I haven't been able to reproduce this, although I understand why it happens:
> vmalloc allocates memory with
> 
> GFP_KERNEL | __GFP_HIGHMEM
> 
> and with git5, the same flags are passed down to cache_alloc_refill, causing
> the BUG. The following patch against 2.6.19-rc3-git5 (also attached as
> attachment, as this mailer may mess up inline copying) should fix it.

Thanks for the patch ... but more worrying is how this got broken.
Wasn't the point of having the -mm tree that patches like this went
through it for testing, and we avoid breaking mainline? especially
this late in the -rc cycle.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
