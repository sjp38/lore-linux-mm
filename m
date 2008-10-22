In-reply-to: <Pine.LNX.4.64.0810221416130.26639@quilx.com> (message from
	Christoph Lameter on Wed, 22 Oct 2008 14:28:57 -0700 (PDT))
Subject: Re: SLUB defrag pull request?
References: <1223883004.31587.15.camel@penberg-laptop>
 <E1Ks1hu-0002nN-9f@pomaz-ex.szeredi.hu>  <48FE6306.6020806@linux-foundation.org>
  <E1KsXrY-0000AU-C4@pomaz-ex.szeredi.hu>  <Pine.LNX.4.64.0810220822500.30851@quilx.com>
  <E1Ksjed-00023D-UB@pomaz-ex.szeredi.hu>  <Pine.LNX.4.64.0810221252570.3562@quilx.com>
  <E1Ksk3g-00027r-Lp@pomaz-ex.szeredi.hu>  <Pine.LNX.4.64.0810221315080.26671@quilx.com>
  <E1KskHI-0002AF-Hz@pomaz-ex.szeredi.hu> <84144f020810221348j536f0d84vca039ff32676e2cc@mail.gmail.com>
 <E1Ksksa-0002Iq-EV@pomaz-ex.szeredi.hu> <Pine.LNX.4.64.0810221416130.26639@quilx.com>
Message-Id: <E1KsluU-0002R1-Ow@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 23 Oct 2008 00:10:34 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: cl@linux-foundation.org
Cc: miklos@szeredi.hu, penberg@cs.helsinki.fi, nickpiggin@yahoo.com.au, hugh@veritas.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Oct 2008, Christoph Lameter wrote:
> On Wed, 22 Oct 2008, Miklos Szeredi wrote:
> 
> >> Actually, when debugging is enabled, it's customary to poison the
> >> object, for example (see free_debug_processing() in mm/slub.c). So we
> >> really can't "easily ensure" that in the allocator unless we by-pass
> >> all the current debugging code.
> 
> Plus the allocator may be reusing parts of the freed object for a freelist 
> etc even if the object is not poisoned.

Actually, no: looking at the slub code it already makes sure that
objects are neither poisoned, nor touched in any way _if_ there is a
constructor for the object.  And for good reason too, otherwise a
reused object would contain rubbish after a second allocation.

Come on guys, you should be the experts in this thing!

So again, just checking d_lru should do work fine.  There's absolutely
no need to mess with extra references in a separate phase, which leads
to lots of complications.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
