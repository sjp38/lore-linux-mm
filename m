Date: Wed, 25 Jun 2008 19:47:13 +0400
From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [patch 1/2] mm: dont clear PG_uptodate in invalidate_complete_page2()
Message-ID: <20080625154713.GA18682@2ka.mipt.ru>
References: <20080625124038.103406301@szeredi.hu> <20080625124121.839734708@szeredi.hu> <20080625131117.GA28136@2ka.mipt.ru> <E1KBV7H-0005nv-Gl@pomaz-ex.szeredi.hu> <20080625141654.GA4803@2ka.mipt.ru> <E1KBWBK-0006Lp-03@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1KBWBK-0006Lp-03@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: jens.axboe@oracle.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, hugh@veritas.com, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Wed, Jun 25, 2008 at 04:41:10PM +0200, Miklos Szeredi (miklos@szeredi.hu) wrote:
> > Is this nfs/fuse problem you described:
> > http://marc.info/?l=linux-fsdevel&m=121396920822693&w=2
> 
> Yes.

I do not know fuse good enough, but it looks like if your patch only
fixes issue for pages which are in splice buffer during invalidation,
any subsequent call for splice() will get correct new data (at least
invoke readpage(s)), but in the description of error there was a
long timeout between reading and writing, so it was a fresh splice()
call, which suddenly started to return errors.

Is it possible that by having uptodate bit in place, but page was
actually freed but not removed from all trees and so on, so it
masked read errors? This may be not the right conclusion though :)

-- 
	Evgeniy Polyakov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
