Date: Wed, 15 Mar 2006 17:55:44 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: page migration reorg patch
Message-Id: <20060315175544.6f9adc59.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0603151736380.30472@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603151736380.30472@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, marcelo.tosatti@cyclades.com, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@sgi.com> wrote:
>
> This patch centralizes the page migration functions in anticipation of 
>  additional tinkering.

That was a bit optimistic :(

bix:/usr/src/25> wc mm/vmscan.c.rej include/linux/swap.h.rej mm/mempolicy.c.rej fs/buffer.c.rej    
    483    2046   12204 mm/vmscan.c.rej
     34     170    1268 include/linux/swap.h.rej
     18      77     613 mm/mempolicy.c.rej
     75     212    1456 fs/buffer.c.rej
    610    2505   15541 total

Am currently sitting on 136 patches which touch mm/*.

If you can rework this patch against
http://www.zip.com.au/~akpm/linux/patches/stuff/x.bz2 (my current queue up
to and including slab-leaks3-locking-fix.patch, against 2.6.16-rc6) then
I'll be able to insert it in the right place and then fix up subsequent
fallout, thanks.


Or we can just do it later.  Whenever that is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
