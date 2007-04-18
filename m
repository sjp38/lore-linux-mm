Date: Wed, 18 Apr 2007 09:12:54 +0300 (EEST)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH] Show slab memory usage on OOM and SysRq-M (v2)
In-Reply-To: <1176831473.12599.30.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0704180912130.11014@sbz-30.cs.Helsinki.FI>
References: <4624E8F4.2090200@sw.ru> <1176831473.12599.30.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <hansendc@us.ibm.com>
Cc: Pavel Emelianov <xemul@sw.ru>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Eric Dumazet <dada1@cosmosbay.com>, Linux MM <linux-mm@kvack.org>, devel@openvz.org, Kirill Korotaev <dev@openvz.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-04-17 at 19:34 +0400, Pavel Emelianov wrote:
> > +#define SHOW_TOP_SLABS 10 

On Tue, 17 Apr 2007, Dave Hansen wrote:
> Real minor nit on this one: SHOW_TOP_SLABS sounds like a bool.  "Should
> I show the top slabs?"
> 
> This might be a bit more clear:
> 
> #define TOP_NR_SLABS_TO_SHOW 10 
> 
> or
> 
> #define NR_SLABS_TO_SHOW 10

Yes. Looks much better.

				Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
