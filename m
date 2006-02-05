Subject: Re: [RFT/PATCH] slab: consolidate allocation paths
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20060204180026.b68e9476.pj@sgi.com>
References: <1139060024.8707.5.camel@localhost>
	 <Pine.LNX.4.62.0602040709210.31909@graphe.net>
	 <1139070369.21489.3.camel@localhost> <1139070779.21489.5.camel@localhost>
	 <20060204180026.b68e9476.pj@sgi.com>
Date: Sun, 05 Feb 2006 10:41:12 +0200
Message-Id: <1139128872.11782.5.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: christoph@lameter.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, manfred@colorfullife.com
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, 2006-02-04 at 18:00 -0800, Paul Jackson wrote:
> Two issues I can see:
> 
>   1) This patch increased the text size of mm/slab.o by 776
>      bytes (ia64 sn2_defconfig gcc 3.3.3), which should be
>      justified.  My naive expectation would have been that
>      such a source code consolidation patch would be text
>      size neutral, or close to it.

Ah, sorry about that, I forgot to verify the NUMA case. The problem is
that to kmalloc_node() is calling cache_alloc() now which is forced
inline. I am wondering, would it be ok to make __cache_alloc()
non-inline for NUMA? The relevant numbers are:

   text    data     bss     dec     hex filename
  15882    2512      24   18418    47f2 mm/slab.o (original)
  16029    2512      24   18565    4885 mm/slab.o (inline)
  15798    2512      24   18334    479e mm/slab.o (non-inline)

>   2) You might want to hold off this patch for a few days,
>      until the dust settles from my memory spread patch.

Sure.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
