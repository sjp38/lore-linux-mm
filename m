Date: Wed, 22 Mar 2000 23:55:45 +0100
From: Jamie Lokier <jamie.lokier@cern.ch>
Subject: Q. about swap-cache orphans
Message-ID: <20000322235545.F31795@pcep-jamie.cern.ch>
References: <20000322190532.A7212@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003221554170.17378-100000@funky.monkey.org> <20000322223351.G2850@redhat.com> <20000322234531.C31795@pcep-jamie.cern.ch> <20000322224818.J2850@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000322224818.J2850@redhat.com>; from Stephen C. Tweedie on Wed, Mar 22, 2000 at 10:48:18PM +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Chuck Lever <cel@monkey.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[This is just a question to help my understanding, not relevant to madvise]

Stephen C. Tweedie wrote:
> If it is the last user of the page --- ie. if PG_SwapCache is set and
> the refcount of the page is one --- then it will do so anyway, because
> when I added that swap cache code I made sure that zap_page_range()
> does a free_page_and_swap_cache() when freeing pages.

I.e., zap_page_range makes sure that MADV_DONTNEED won't leave orphan
swap-cache pages.

> > Doesn't this also result in a swap-cache leak, or are orphan swap-cache
> > pages reclaimed eventually?
> 
> The shrink_mmap() page cache reclaimer is able to pick up any orphaned 
> swap cache pages.

But there won't be any orphans, will there?
Or do they appear due to async. swapping situations?

thanks,
-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
