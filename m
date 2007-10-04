In-reply-to: <1191516427.5574.7.camel@lappy> (message from Peter Zijlstra on
	Thu, 04 Oct 2007 18:47:07 +0200)
Subject: Re: [PATCH] remove throttle_vm_writeout()
References: <E1IdPla-0002Bd-00@dorka.pomaz.szeredi.hu>
	 <1191501626.22357.14.camel@twins>
	 <E1IdQJn-0002Cv-00@dorka.pomaz.szeredi.hu>
	 <1191504186.22357.20.camel@twins>
	 <E1IdR58-0002Fq-00@dorka.pomaz.szeredi.hu> <1191516427.5574.7.camel@lappy>
Message-Id: <E1IdXuZ-0002Sk-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 04 Oct 2007 23:07:11 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, wfg@mail.ustc.edu.cn, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Yeah, I'm guestimating O on a per device basis, but I agree that the
> current ratio limiting is quite crude. I'm not at all sorry to see
> throttle_vm_writeback() go, I just wanted to make a point that what it
> does is not quite without merrit - we agree that it can be done better
> differently.

Yes.  So what is it to be?

Is limiting by device queues enough?

Or do we need some global limit?

If so, the cleanest way I see is to separately account and limit
swap-writeback pages, so the global counters don't interfere with the
limiting.

This shouldn't be hard to do, as we have the per-bdi writeback
counting infrastructure already, and also a pseudo bdi for swap in
swapper_space.backing_dev_info.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
