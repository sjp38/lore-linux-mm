Message-ID: <47D06A84.8060508@cs.helsinki.fi>
Date: Fri, 07 Mar 2008 00:04:52 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [BUG] in 2.6.25-rc3 with 64k page size and SLUB_DEBUG_ON
References: <200803061447.05797.Jens.Osterkamp@gmx.de> <200803062207.37654.Jens.Osterkamp@gmx.de> <Pine.LNX.4.64.0803061349220.15083@schroedinger.engr.sgi.com> <200803062253.00034.Jens.Osterkamp@gmx.de> <Pine.LNX.4.64.0803061354210.15083@schroedinger.engr.sgi.com> <47D06993.9000703@cs.helsinki.fi>
In-Reply-To: <47D06993.9000703@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Jens Osterkamp <Jens.Osterkamp@gmx.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Pekka Enberg wrote:
> You mention slub_debug=- makes the problem go away but can you narrow it 
> down to a specific debug option described in Documentation/vm/slub.txt? 
> In particular, does disabling slab poisoning or red zoning make the 
> problem go away also?

The most important thing to check is whether the kernel crashes with 
slub_debug=f. That option enables all the debug paths but doesn't change 
memory layout or contents at all (unlike red-zoning and poisoning).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
