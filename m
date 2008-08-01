Date: Fri, 1 Aug 2008 11:32:48 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch v3] splice: fix race with page invalidation
In-Reply-To: <E1KOzMt-0003fa-Ah@pomaz-ex.szeredi.hu>
Message-ID: <alpine.LFD.1.10.0808011131500.3277@nehalem.linux-foundation.org>
References: <E1KO8DV-0004E4-6H@pomaz-ex.szeredi.hu> <alpine.LFD.1.10.0807310957200.3277@nehalem.linux-foundation.org> <E1KOceD-0000nD-JA@pomaz-ex.szeredi.hu> <200808011122.51792.nickpiggin@yahoo.com.au> <E1KOzMt-0003fa-Ah@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: nickpiggin@yahoo.com.au, jens.axboe@oracle.com, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 1 Aug 2008, Miklos Szeredi wrote:
>
> Subject: mm: dont clear PG_uptodate on truncate/invalidate 
> From: Miklos Szeredi <mszeredi@suse.cz>

Ok, this one I have no problems with what-so-ever. I'd like Ack's for this 
kind of change (and obviously hope that it's tested), but it looks clean 
and I think the new rules are better (not just for this case).

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
