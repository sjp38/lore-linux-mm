Subject: Re: SLUB defrag pull request?
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <E1KsluU-0002R1-Ow@pomaz-ex.szeredi.hu>
References: <1223883004.31587.15.camel@penberg-laptop>
	 <E1Ks1hu-0002nN-9f@pomaz-ex.szeredi.hu>
	 <48FE6306.6020806@linux-foundation.org>
	 <E1KsXrY-0000AU-C4@pomaz-ex.szeredi.hu>
	 <Pine.LNX.4.64.0810220822500.30851@quilx.com>
	 <E1Ksjed-00023D-UB@pomaz-ex.szeredi.hu>
	 <Pine.LNX.4.64.0810221252570.3562@quilx.com>
	 <E1Ksk3g-00027r-Lp@pomaz-ex.szeredi.hu>
	 <Pine.LNX.4.64.0810221315080.26671@quilx.com>
	 <E1KskHI-0002AF-Hz@pomaz-ex.szeredi.hu>
	 <84144f020810221348j536f0d84vca039ff32676e2cc@mail.gmail.com>
	 <E1Ksksa-0002Iq-EV@pomaz-ex.szeredi.hu>
	 <Pine.LNX.4.64.0810221416130.26639@quilx.com>
	 <E1KsluU-0002R1-Ow@pomaz-ex.szeredi.hu>
Content-Type: text/plain; charset=UTF-8
Date: Thu, 23 Oct 2008 10:10:31 +0300
Message-Id: <1224745831.25814.21.camel@penberg-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: cl@linux-foundation.org, nickpiggin@yahoo.com.au, hugh@veritas.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Hi Miklos,

i>>?On Thu, 2008-10-23 at 00:10 +0200, Miklos Szeredi wrote:i>>?
> Actually, no: looking at the slub code it already makes sure that
> objects are neither poisoned, nor touched in any way _if_ there is a
> constructor for the object. And for good reason too, otherwise a
> reused object would contain rubbish after a second allocation.

There's no inherent reason why we cannot poison slab caches with a
constructor. As a matter of fact SLAB does it which is probably why I
got confused here. The only thing that needs to disable slab poisoning
by design is SLAB_DESTROY_BY_RCU.

But for SLUB, you're obviously right.

i>>?On Thu, 2008-10-23 at 00:10 +0200, Miklos Szeredi wrote:
> Come on guys, you should be the experts in this thing!

Yeah, I know. Yet you're stuck with us. That's sad.

		Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
