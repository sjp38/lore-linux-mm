Message-ID: <47D06F07.4070404@cs.helsinki.fi>
Date: Fri, 07 Mar 2008 00:24:07 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [BUG] in 2.6.25-rc3 with 64k page size and SLUB_DEBUG_ON
References: <200803061447.05797.Jens.Osterkamp@gmx.de> <Pine.LNX.4.64.0803061354210.15083@schroedinger.engr.sgi.com> <47D06993.9000703@cs.helsinki.fi> <200803062307.22436.Jens.Osterkamp@gmx.de> <Pine.LNX.4.64.0803061418430.15083@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0803061418430.15083@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Jens Osterkamp <Jens.Osterkamp@gmx.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Ahh.. That looks like an alignment problem. The other options all add 
> data to the object and thus misalign them if no alignment is 
> specified.

And causes buffer overrun? So the crazy preempt count 0x00056ef8 could a 
the lower part of an instruction pointer tracked by SLAB_STORE_USER? So 
does:

   gdb vmlinux
   (gdb) l *c000000000056ef8

translate into any meaningful kernel function?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
