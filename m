Date: Sat, 23 Apr 2005 07:31:41 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC] non-resident page management
In-Reply-To: <1114255557.10805.2.camel@localhost>
Message-ID: <Pine.LNX.4.61.0504230730560.26710@chimarrao.boston.redhat.com>
References: <1114255557.10805.2.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 23 Apr 2005, Pekka Enberg wrote:
> On 4/23/05, Rik van Riel <riel@redhat.com> wrote:
> > Note that this code could use an actual hash function.
> 
> How about this? It computes hash for the two longs and combines them by
> addition and multiplication as suggested by [Bloch01].

I've thought about it, but ...

> @@ -23,7 +23,7 @@
>  #error Define GOLDEN_RATIO_PRIME for your wordsize.
>  #endif

... include/linux/hash.c appears to only work right for
32 bit words, not 64 bit ones ...

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
