Date: Mon, 18 Jun 2007 15:34:06 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 05/26] Slab allocators: Cleanup zeroing allocations
In-Reply-To: <84144f020706181326i6923cccdm21d122ee9eee8fb7@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0706181531410.8595@schroedinger.engr.sgi.com>
References: <20070618095838.238615343@sgi.com>  <20070618095914.622685354@sgi.com>
  <84144f020706181316u70145db2i786641d265e5bc42@mail.gmail.com>
 <84144f020706181326i6923cccdm21d122ee9eee8fb7@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

On Mon, 18 Jun 2007, Pekka Enberg wrote:

> On 6/18/07, Pekka Enberg <penberg@cs.helsinki.fi> wrote:
> > Hmm, did you check kernel text size before and after this change?
> > Setting the __GFP_ZERO flag at every kzalloc call-site seems like a
> > bad idea.
> 
> Aah but most call-sites, of course, use constants such as GFP_KERNEL
> only which should be folded nicely by the compiler. So this probably
> doesn't have much impact. Would be nice if you'd check, though.

IA64

Before:

   text    data     bss     dec     hex filename
10486815        4128471 3686044 18301330        1174192 vmlinux

After:

   text    data     bss     dec     hex filename
10486335        4128439 3686044 18300818        1173f92 vmlinux

Saved ~500 bytes in text size.

x86_64:

Before:

   text    data     bss     dec     hex filename
3823932  333840  220484 4378256  42ce90 vmlinux

After

   text    data     bss     dec     hex filename
3823716  333840  220484 4378040  42cdb8 vmlinux

200 bytes saved.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
