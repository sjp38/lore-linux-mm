Date: Sat, 4 Feb 2006 07:11:12 -0800 (PST)
From: Christoph Lameter <christoph@lameter.com>
Subject: Re: [RFT/PATCH] slab: consolidate allocation paths
In-Reply-To: <1139060024.8707.5.camel@localhost>
Message-ID: <Pine.LNX.4.62.0602040709210.31909@graphe.net>
References: <1139060024.8707.5.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, manfred@colorfullife.com, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Sat, 4 Feb 2006, Pekka Enberg wrote:

> I don't have access to NUMA machine and would appreciate if someone
> could give this patch a spin and let me know I didn't break anything.

No time to do a full review (off to traffic school... sigh), I did not 
see anything by just glancing over it but the patch will conflict with 
Paul Jacksons patchset to implement memory spreading.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
