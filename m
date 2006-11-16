Date: Wed, 15 Nov 2006 16:45:29 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/2] enables booting a NUMA system where some nodes have
 no memory
In-Reply-To: <200611160126.02016.arnd@arndb.de>
Message-ID: <Pine.LNX.4.64.0611151643420.24457@schroedinger.engr.sgi.com>
References: <20061115193049.3457b44c@localhost> <455B8F3A.6030503@mbligh.org>
 <Pine.LNX.4.64.0611151440400.23201@schroedinger.engr.sgi.com>
 <200611160126.02016.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Martin Bligh <mbligh@mbligh.org>, Christian Krafft <krafft@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 16 Nov 2006, Arnd Bergmann wrote:

> - we want to be able to boot with the 'mem=512M' option, which effectively
>   disables the memory on the second node (each node has 512MiB).
> - Each node has 8 SPUs, all of which we want to use. In order to use an
>   SPU, we call __add_pages to register the local memory on it, so we have
>   struct page pointers we can hand out to user mappings with ->nopage().

This is more like the bringup of a processor right? You need
to have the memory online before the processor is brought up otherwise
the slab cannot properly allocate its structures on the node when the
per node portion is brought up. The page allocator has similar issues.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
