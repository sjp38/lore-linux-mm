In-reply-to: <1224745831.25814.21.camel@penberg-laptop> (message from Pekka
	Enberg on Thu, 23 Oct 2008 10:10:31 +0300)
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
	 <E1KskHI-0002AF-Hz@pomaz-ex.szeredi.hu>
	 <84144f020810221348j536f0d84vca039ff32676e2cc@mail.gmail.com>
	 <E1Ksksa-0002Iq-EV@pomaz-ex.szeredi.hu>
	 <Pine.LNX.4.64.0810221416130.26639@quilx.com>
	 <E1KsluU-0002R1-Ow@pomaz-ex.szeredi.hu> <1224745831.25814.21.camel@penberg-laptop>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Message-Id: <E1KsviY-0003Mq-6M@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 23 Oct 2008 10:38:54 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: penberg@cs.helsinki.fi
Cc: miklos@szeredi.hu, cl@linux-foundation.org, nickpiggin@yahoo.com.au, hugh@veritas.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 23 Oct 2008, Pekka Enberg wrote:
> i>>?On Thu, 2008-10-23 at 00:10 +0200, Miklos Szeredi wrote:i>>?
> > Actually, no: looking at the slub code it already makes sure that
> > objects are neither poisoned, nor touched in any way _if_ there is a
> > constructor for the object. And for good reason too, otherwise a
> > reused object would contain rubbish after a second allocation.
> 
> There's no inherent reason why we cannot poison slab caches with a
> constructor.

Right, it just needs to call the constructor for every allocation.

> > Come on guys, you should be the experts in this thing!
> 
> Yeah, I know. Yet you're stuck with us. That's sad.

No, I was a bit rude, sorry.

I think the _real_ problem is that instead of fancy features like this
defragmenter, SLUB should first concentrate on getting the code solid
enough to replace the other allocators.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
