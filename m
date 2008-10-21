Message-ID: <48FE6306.6020806@linux-foundation.org>
Date: Tue, 21 Oct 2008 18:17:26 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: SLUB defrag pull request?
References: <1223883004.31587.15.camel@penberg-laptop> <1223883164.31587.16.camel@penberg-laptop> <Pine.LNX.4.64.0810131227120.20511@blonde.site> <200810132354.30789.nickpiggin@yahoo.com.au> <E1KpNwq-0003OW-8f@pomaz-ex.szeredi.hu> <E1KpOOL-0003Vf-9y@pomaz-ex.szeredi.hu> <48F378C6.7030206@linux-foundation.org> <E1KpOjX-0003dt-AY@pomaz-ex.szeredi.hu> <48FC9CCC.3040006@linux-foundation.org> <E1Krz4o-0002Fi-Pu@pomaz-ex.szeredi.hu> <48FCCC72.5020202@linux-foundation.org> <E1KrzgK-0002QS-Os@pomaz-ex.szeredi.hu> <48FCD7CB.4060505@linux-foundation.org> <E1Ks0QX-0002aC-SQ@pomaz-ex.szeredi.hu> <48FCE1C4.20807@linux-foundation.org> <E1Ks1hu-0002nN-9f@pomaz-ex.szeredi.hu>
In-Reply-To: <E1Ks1hu-0002nN-9f@pomaz-ex.szeredi.hu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: penberg@cs.helsinki.fi, nickpiggin@yahoo.com.au, hugh@veritas.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Miklos Szeredi wrote:
> On Mon, 20 Oct 2008, Christoph Lameter wrote:
>> Miklos Szeredi wrote:
>>> So, isn't it possible to do without get_dentries()?  What's the
>>> fundamental difference between this and regular cache shrinking?
>> The fundamental difference is that slab defrag operates on sparsely
>> populated dentries. It comes into effect when the density of
>> dentries per page is low and lots of memory is wasted. It
>> defragments by kicking out dentries in low density pages. These can
>> then be reclaimed.
> 
> OK, but why can't this be done in just one stage?

The only way that a secure reference can be established is if the slab page is
locked. That requires a spinlock. The slab allocator calls the get() functions
 while the slab lock guarantees object existence. Then locks are dropped and
reclaim actions can start with the guarantee that the slab object will not
suddenly vanish.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
