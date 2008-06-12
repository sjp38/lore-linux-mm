Date: Thu, 12 Jun 2008 10:13:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: repeatable slab corruption with LTP msgctl08
In-Reply-To: <Pine.LNX.4.64.0806121332130.11556@sbz-30.cs.Helsinki.FI>
Message-ID: <Pine.LNX.4.64.0806121011320.30597@schroedinger.engr.sgi.com>
References: <20080611221324.42270ef2.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0806121332130.11556@sbz-30.cs.Helsinki.FI>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nadia Derbey <Nadia.Derbey@bull.net>, Manfred Spraul <manfred@colorfullife.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 12 Jun 2008, Pekka J Enberg wrote:

> I really don't understand how your bufctl chains has so many BUFCTL_END 
> elements in the first place. It's doesn't look like the memory has been 
> stomped on (slab->s_mem, for example, is 0xf2906088), so I'd look for a 
> double kfree() of size 128 somewhere...

Looks pretty strange. Could this be rerun with SLAB_DEBUG or with SLUB 
with full debugging?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
