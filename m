In-reply-to: <Pine.LNX.4.64.0810221315080.26671@quilx.com> (message from
	Christoph Lameter on Wed, 22 Oct 2008 13:19:15 -0700 (PDT))
Subject: Re: SLUB defrag pull request?
References: <1223883004.31587.15.camel@penberg-laptop>
 <1223883164.31587.16.camel@penberg-laptop> <Pine.LNX.4.64.0810131227120.20511@blonde.site>
 <200810132354.30789.nickpiggin@yahoo.com.au> <E1KpNwq-0003OW-8f@pomaz-ex.szeredi.hu>
 <E1KpOOL-0003Vf-9y@pomaz-ex.szeredi.hu> <48F378C6.7030206@linux-foundation.org>
 <E1KpOjX-0003dt-AY@pomaz-ex.szeredi.hu> <48FC9CCC.3040006@linux-foundation.org>
 <E1Krz4o-0002Fi-Pu@pomaz-ex.szeredi.hu> <48FCCC72.5020202@linux-foundation.org>
 <E1KrzgK-0002QS-Os@pomaz-ex.szeredi.hu> <48FCD7CB.4060505@linux-foundation.org>
 <E1Ks0QX-0002aC-SQ@pomaz-ex.szeredi.hu> <48FCE1C4.20807@linux-foundation.org>
 <E1Ks1hu-0002nN-9f@pomaz-ex.szeredi.hu> <48FE6306.6020806@linux-foundation.org>
 <E1KsXrY-0000AU-C4@pomaz-ex.szeredi.hu> <Pine.LNX.4.64.0810220822500.30851@quilx.com>
 <E1Ksjed-00023D-UB@pomaz-ex.szeredi.hu> <Pine.LNX.4.64.0810221252570.3562@quilx.com>
 <E1Ksk3g-00027r-Lp@pomaz-ex.szeredi.hu> <Pine.LNX.4.64.0810221315080.26671@quilx.com>
Message-Id: <E1KskHI-0002AF-Hz@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 22 Oct 2008 22:26:00 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: cl@linux-foundation.org
Cc: miklos@szeredi.hu, penberg@cs.helsinki.fi, nickpiggin@yahoo.com.au, hugh@veritas.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Oct 2008, Christoph Lameter wrote:
> On Wed, 22 Oct 2008, Miklos Szeredi wrote:
> 
> > You are not actually listening to what I'm saying.  Please read the
> > question carefully again.
> 
> That is the impression that I got from you too. I have listed the options 
> to get a reliable reference to an object and you seem to just skip over 
> it.

Because you don't _need_ a reliable reference to access the contents
of the dentry.  The dentry is still there after being freed, as long
as the underlying slab is there and isn't being reused for some other
purpose.  But you can easily ensure that from the slab code.

Hmm?

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
