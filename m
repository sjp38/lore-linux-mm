Date: Thu, 6 Mar 2008 14:20:15 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [BUG] in 2.6.25-rc3 with 64k page size and SLUB_DEBUG_ON
In-Reply-To: <200803062307.22436.Jens.Osterkamp@gmx.de>
Message-ID: <Pine.LNX.4.64.0803061418430.15083@schroedinger.engr.sgi.com>
References: <200803061447.05797.Jens.Osterkamp@gmx.de>
 <Pine.LNX.4.64.0803061354210.15083@schroedinger.engr.sgi.com>
 <47D06993.9000703@cs.helsinki.fi> <200803062307.22436.Jens.Osterkamp@gmx.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Osterkamp <Jens.Osterkamp@gmx.de>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 6 Mar 2008, Jens Osterkamp wrote:

> > You mention slub_debug=- makes the problem go away but can you narrow it 
> > down to a specific debug option described in Documentation/vm/slub.txt? 
> > In particular, does disabling slab poisoning or red zoning make the 
> > problem go away also?
> 
> I tried with slub_debug= F,Z,P and U. Only with F the problem is not there.

Ahh.. That looks like an alignment problem. The other options all add 
data to the object and thus misalign them if no alignment is 
specified.

Seems that powerpc expect an alignment but does not specify it for some data.

You can restrict the debug for certain slabs only. Try some of the arch 
specific slab caches first.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
