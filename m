Date: Wed, 12 Sep 2007 14:11:28 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH 04 of 24] serialize oom killer
Message-ID: <20070912121128.GH21600@v2.random>
References: <patchbomb.1187786927@v2.random> <871b7a4fd566de081120.1187786931@v2.random> <20070912050205.a6b243a2.akpm@linux-foundation.org> <20070912050447.2722f4dc.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070912050447.2722f4dc.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 12, 2007 at 05:04:47AM -0700, Andrew Morton wrote:
> Is there some reason why it had to be a semaphore?  Does it get upped by
> tasks which didn't down it?  Does the semaphore counting feature get used?

No you're right this can be a mutex. the reason this is a semaphore is
that those bugs had to be fixed against a 2.6.5 kernel first ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
