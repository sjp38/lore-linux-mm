Date: Wed, 30 Jul 2008 13:13:48 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch v3] splice: fix race with page invalidation
In-Reply-To: <E1KOHvq-0001oX-OW@pomaz-ex.szeredi.hu>
Message-ID: <alpine.LFD.1.10.0807301310130.3334@nehalem.linux-foundation.org>
References: <E1KO8DV-0004E4-6H@pomaz-ex.szeredi.hu> <alpine.LFD.1.10.0807300958390.3334@nehalem.linux-foundation.org> <E1KOFUi-0000EU-0p@pomaz-ex.szeredi.hu> <20080730175406.GN20055@kernel.dk> <E1KOGT8-0000rd-0Z@pomaz-ex.szeredi.hu> <E1KOGeO-0000yi-EM@pomaz-ex.szeredi.hu>
 <20080730194516.GO20055@kernel.dk> <E1KOHvq-0001oX-OW@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: jens.axboe@oracle.com, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 30 Jul 2008, Miklos Szeredi wrote:
> 
> Take this patch as a bugfix.  It's not in any way showing the way
> forward: as soon as you have the time, you can revert it and start
> from the current state.
> 
> Hmm?

I dislike that mentality.

The fact is, it's not a bug-fix, it's just papering over the real problem.

And by papering it over, it then just makes people less likely to bother 
with the real issue.

For example, and I talked about this earlier - what make syou think that 
the FUSE/NFSD behaviour you don't like is at all valid in the first place?

If you depend on data not being truncated because you have it "in flight", 
tjhere's already something wrong there. It's _not_ just that people can 
see zero bytes in the reply - apparently they can see the file shrink 
before they see the read return. That kind of thing just worries me. And 
it might be a general NFS issue, not necessarily a FUSE one.

So I think your whole approach stinks. I don't agree with the "bug-fix". 
It really smells like a "bug-paper-over".

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
