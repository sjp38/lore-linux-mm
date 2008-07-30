Date: Wed, 30 Jul 2008 10:00:28 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch v3] splice: fix race with page invalidation
In-Reply-To: <E1KO8DV-0004E4-6H@pomaz-ex.szeredi.hu>
Message-ID: <alpine.LFD.1.10.0807300958390.3334@nehalem.linux-foundation.org>
References: <E1KO8DV-0004E4-6H@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: jens.axboe@oracle.com, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 30 Jul 2008, Miklos Szeredi wrote:
> 
> There are no real disadvantages: splice() from a file was originally meant to
> be asynchronous, but in reality it only did that for non-readahead pages,
> which happen rarely.

I still don't like this. I still don't see the point, and I still think 
there is something fundamentally wrong elsewhere.

I also object to just dismissing the async nature as unimportant. Fix it 
instead. Make it use generic_file_readahead() or something. This is fixing 
things in all the wrong places, imnsho.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
