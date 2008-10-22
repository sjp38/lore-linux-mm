Date: Wed, 22 Oct 2008 13:59:54 -0700 (PDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: SLUB defrag pull request?
In-Reply-To: <E1KskHI-0002AF-Hz@pomaz-ex.szeredi.hu>
Message-ID: <Pine.LNX.4.64.0810221341500.26671@quilx.com>
References: <1223883004.31587.15.camel@penberg-laptop>
 <Pine.LNX.4.64.0810131227120.20511@blonde.site> <200810132354.30789.nickpiggin@yahoo.com.au>
 <E1KpNwq-0003OW-8f@pomaz-ex.szeredi.hu> <E1KpOOL-0003Vf-9y@pomaz-ex.szeredi.hu>
 <48F378C6.7030206@linux-foundation.org> <E1KpOjX-0003dt-AY@pomaz-ex.szeredi.hu>
 <48FC9CCC.3040006@linux-foundation.org> <E1Krz4o-0002Fi-Pu@pomaz-ex.szeredi.hu>
 <48FCCC72.5020202@linux-foundation.org> <E1KrzgK-0002QS-Os@pomaz-ex.szeredi.hu>
 <48FCD7CB.4060505@linux-foundation.org> <E1Ks0QX-0002aC-SQ@pomaz-ex.szeredi.hu>
 <48FCE1C4.20807@linux-foundation.org> <E1Ks1hu-0002nN-9f@pomaz-ex.szeredi.hu>
 <48FE6306.6020806@linux-foundation.org> <E1KsXrY-0000AU-C4@pomaz-ex.szeredi.hu>
 <Pine.LNX.4.64.0810220822500.30851@quilx.com> <E1Ksjed-00023D-UB@pomaz-ex.szeredi.hu>
 <Pine.LNX.4.64.0810221252570.3562@quilx.com> <E1Ksk3g-00027r-Lp@pomaz-ex.szeredi.hu>
 <Pine.LNX.4.64.0810221315080.26671@quilx.com> <E1KskHI-0002AF-Hz@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: penberg@cs.helsinki.fi, nickpiggin@yahoo.com.au, hugh@veritas.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Oct 2008, Miklos Szeredi wrote:

>> That is the impression that I got from you too. I have listed the options
>> to get a reliable reference to an object and you seem to just skip over
>> it.
>
> Because you don't _need_ a reliable reference to access the contents
> of the dentry.  The dentry is still there after being freed, as long
> as the underlying slab is there and isn't being reused for some other
> purpose.  But you can easily ensure that from the slab code.

With the two callbacks that I described that would take the global 
lock? That was already discussed before. Please read! It does not scale 
and the lock would have to be acquired before objects in a slab page are 
scanned and handled in any way.

Without that locking any other processor can go into reclaim and start 
evicting the dentries that we are operating upon.

Freeing in the slab sense means that a kfree ran to get rid of the 
object.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
