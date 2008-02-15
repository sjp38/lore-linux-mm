Date: Fri, 15 Feb 2008 14:43:34 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 3/4] x86_64: Fold pda into per cpu area
In-Reply-To: <20080215201640.GA6200@elte.hu>
Message-ID: <Pine.LNX.4.64.0802151442440.16270@schroedinger.engr.sgi.com>
References: <20080201191414.961558000@sgi.com> <20080201191415.450555000@sgi.com>
 <20080215201640.GA6200@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: travis@sgi.com, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Thomas Gleixner <tglx@linutronix.de>, Jeremy Fitzhardinge <jeremy@goop.org>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 15 Feb 2008, Ingo Molnar wrote:

> 
> * travis@sgi.com <travis@sgi.com> wrote:
> 
> >  include/asm-generic/vmlinux.lds.h |    2 +
> >  include/linux/percpu.h            |    9 ++++-
> 
> couldnt these two generic bits be done separately (perhaps a preparatory 
> but otherwise NOP patch pushed upstream straight away) to make 
> subsequent patches only touch x86 architecture files?

Yes those modifications could be folded into the generic patch for zero 
based percpu configurations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
