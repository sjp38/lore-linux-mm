Date: Tue, 27 May 2008 11:46:27 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 2/2] lockless get_user_pages
In-Reply-To: <20080527022801.GB21578@wotan.suse.de>
References: <20080527095519.4676.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080527022801.GB21578@wotan.suse.de>
Message-Id: <20080527114350.4679.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com, Johannes Weiner <hannes@saeurebad.de>, Andrew Morton <akpm@linux-foundation.org>, shaggy@austin.ibm.com, jens.axboe@oracle.com, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

> Aw, nobody likes fast_gup? ;)

Ah, I misunderstood your intention.
I thought you disklike fast_gup..

I don't dislike it :()

> 
> Technically get_user_pages_lockless is wrong: the implementation may
> not be lockless so one cannot assume it will not take mmap sem and
> ptls.

agreed.


> But I do like to make it clear that it is related to get_user_pages.
> get_current_user_pages(), maybe? Hmm, that's harder to grep for
> both then I guess. get_user_pages_current?

Yeah, good name.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
