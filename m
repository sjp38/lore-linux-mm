Date: Wed, 23 Jan 2002 20:12:48 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH *] rmap VM, version 12
Message-ID: <20020123201248.A27249@wotan.suse.de>
References: <OFB07135FF.E6C5BE7E-ON88256B4A.0068CB3F@boulder.ibm.com> <Pine.LNX.4.33L.0201231704430.32617-100000@imladris.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33L.0201231704430.32617-100000@imladris.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Badari Pulavarty <badari@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 23, 2002 at 05:05:13PM -0200, Rik van Riel wrote:
> > uncompressing linux ...
> > booting ..
> 
> At this point we're not even near using pagetables yet,
> so I guess this is something else ...
> 
> (I'm not 100% sure, though)

It happens when you crash before console initialization.  VM is already
low level initialized there, but other CPUs should not have been booted yet.

Usual way to debug is to link with one of the patches that replace printk
with an "early_printk" that writes directly into the vga text buffer and
works without the console subsystem. 

-andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
