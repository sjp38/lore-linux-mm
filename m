Date: Sat, 9 Jul 2005 18:06:11 -0700 (PDT)
From: Christoph Lameter <christoph@lameter.com>
Subject: Re: [PATCH] Early kmalloc/kfree
In-Reply-To: <p73zmsxncym.fsf@verdi.suse.de>
Message-ID: <Pine.LNX.4.62.0507091801170.22975@graphe.net>
References: <20050708203807.GG27544@localhost.localdomain.suse.lists.linux.kernel>
 <p73zmsxncym.fsf@verdi.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Bob Picco <bob.picco@hp.com>, linux-mm@kvack.org, manfred@colorfullife.com, alex.williamson@hp.com, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Fri, 9 Jul 2005, Andi Kleen wrote:

> I think that is a really really bad idea.   slab is already complex enough
> and adding scary hacks like this will probably make it collapse
> under its own weight at some point.

Seconded.

Maybe we can solve this by bringing the system up in a limited 
configuration and then discover additional capabilities during ACPI 
discovery and reconfigure.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
