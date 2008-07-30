Date: Wed, 30 Jul 2008 14:22:13 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch v3] splice: fix race with page invalidation
In-Reply-To: <E1KOJ1s-0002a5-Im@pomaz-ex.szeredi.hu>
Message-ID: <alpine.LFD.1.10.0807301418270.3277@nehalem.linux-foundation.org>
References: <E1KO8DV-0004E4-6H@pomaz-ex.szeredi.hu> <alpine.LFD.1.10.0807300958390.3334@nehalem.linux-foundation.org> <E1KOFUi-0000EU-0p@pomaz-ex.szeredi.hu> <20080730175406.GN20055@kernel.dk> <E1KOGT8-0000rd-0Z@pomaz-ex.szeredi.hu> <E1KOGeO-0000yi-EM@pomaz-ex.szeredi.hu>
 <20080730194516.GO20055@kernel.dk> <E1KOHvq-0001oX-OW@pomaz-ex.szeredi.hu> <alpine.LFD.1.10.0807301310130.3334@nehalem.linux-foundation.org> <E1KOIYA-0002FG-Rg@pomaz-ex.szeredi.hu> <alpine.LFD.1.10.0807301349020.3334@nehalem.linux-foundation.org>
 <E1KOJ1s-0002a5-Im@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: jens.axboe@oracle.com, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 30 Jul 2008, Miklos Szeredi wrote:
> 
> Huh?  I did exactly that, and that patch got NAK'ed by you and Nick:

Umm. That was during the late -rc sequence (what, -rc8?) where I wanted a 
minimal "let's fix it". Not that anybody then apparently cared, which is 
probably just as well.

Then you did NOTHING AT ALL about it, now the merge window is over, and 
you complain again, with what looks like basically the same patch that was 
already rejected earlier.

Hellooo..

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
