Received: by py-out-1112.google.com with SMTP id f47so2949691pye.20
        for <linux-mm@kvack.org>; Wed, 23 Apr 2008 19:03:12 -0700 (PDT)
Message-ID: <44c63dc40804231903m654736e7k47d79373d5449571@mail.gmail.com>
Date: Thu, 24 Apr 2008 11:03:11 +0900
From: "minchan Kim" <barrioskmc@gmail.com>
Subject: wrong comment in do_try_to_free_pages ?
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

static unsigned long do_try_to_free_pages(struct zone **zones, gfp_t gfp_mask,
           struct scan_control *sc)
...
...
   /* Take a nap, wait for some writeback to complete */
   if (sc->nr_scanned && priority < DEF_PRIORITY - 2)
     congestion_wait(WRITE, HZ/10);
 }
 /* top priority shrink_caches still had more to do? don't OOM, then */
                     ^^^^^^^^^^^^^^^^^
 if (!sc->all_unreclaimable && scan_global_lru(sc))
   ret = 1;
out:
 /*
....

I think we change shrink_caches commet with shrink_zone.

And I can't understand that's comment.

What's role sc->all_unreclaimable ?
What benefit do we can get with that code ?
If we don't have that code, What's problem happen ?

-- 
Thanks,
barrios

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
