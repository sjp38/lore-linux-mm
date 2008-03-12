Date: Wed, 12 Mar 2008 16:34:15 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [BUG] in 2.6.25-rc3 with 64k page size and SLUB_DEBUG_ON
In-Reply-To: <200803121619.45708.Jens.Osterkamp@gmx.de>
Message-ID: <Pine.LNX.4.64.0803121630110.10488@schroedinger.engr.sgi.com>
References: <200803061447.05797.Jens.Osterkamp@gmx.de>
 <200803072330.46448.Jens.Osterkamp@gmx.de> <Pine.LNX.4.64.0803071453170.9654@schroedinger.engr.sgi.com>
 <200803121619.45708.Jens.Osterkamp@gmx.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Osterkamp <Jens.Osterkamp@gmx.de>
Cc: Pekka J Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 12 Mar 2008, Jens Osterkamp wrote:

> I added a printk in kmalloc and the size seems to be 0x4000.

Hmmmm... So kmalloc_index returns 14. This should all be fine.

However, with slub_debug the size of the 16k kmalloc object is 
actually a bit larger than 0x4000. The caller must not expect the object 
to be aligned to a 16kb boundary. Is that the case?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
