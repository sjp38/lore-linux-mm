In-reply-to: <84144f020810221348j536f0d84vca039ff32676e2cc@mail.gmail.com>
	(penberg@cs.helsinki.fi)
Subject: Re: SLUB defrag pull request?
References: <1223883004.31587.15.camel@penberg-laptop>
	 <E1Ks1hu-0002nN-9f@pomaz-ex.szeredi.hu>
	 <48FE6306.6020806@linux-foundation.org>
	 <E1KsXrY-0000AU-C4@pomaz-ex.szeredi.hu>
	 <Pine.LNX.4.64.0810220822500.30851@quilx.com>
	 <E1Ksjed-00023D-UB@pomaz-ex.szeredi.hu>
	 <Pine.LNX.4.64.0810221252570.3562@quilx.com>
	 <E1Ksk3g-00027r-Lp@pomaz-ex.szeredi.hu>
	 <Pine.LNX.4.64.0810221315080.26671@quilx.com>
	 <E1KskHI-0002AF-Hz@pomaz-ex.szeredi.hu> <84144f020810221348j536f0d84vca039ff32676e2cc@mail.gmail.com>
Message-Id: <E1Ksksa-0002Iq-EV@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 22 Oct 2008 23:04:32 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: penberg@cs.helsinki.fi
Cc: miklos@szeredi.hu, cl@linux-foundation.org, nickpiggin@yahoo.com.au, hugh@veritas.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Oct 2008, Pekka Enberg wrote:
> On Wed, Oct 22, 2008 at 11:26 PM, Miklos Szeredi <miklos@szeredi.hu> wrote:
> > Because you don't _need_ a reliable reference to access the contents
> > of the dentry.  The dentry is still there after being freed, as long
> > as the underlying slab is there and isn't being reused for some other
> > purpose.  But you can easily ensure that from the slab code.
> >
> > Hmm?
> 
> Actually, when debugging is enabled, it's customary to poison the
> object, for example (see free_debug_processing() in mm/slub.c). So we
> really can't "easily ensure" that in the allocator unless we by-pass
> all the current debugging code.

Thank you, that does actually answer my question.  I would still think
it's a good sacrifice to no let the dentries be poisoned for the sake
of a simpler dentry defragmenter.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
