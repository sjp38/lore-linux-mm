Message-ID: <4803C030.4080808@cs.helsinki.fi>
Date: Mon, 14 Apr 2008 23:36:00 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: RIP __kmem_cache_shrink (was Re: [patch 15/18] FS: Proc	filesystem
 support for slab defrag)
References: <20080404230158.365359425@sgi.com> <20080404230229.169327879@sgi.com> <20080407231346.8a17d27d.akpm@linux-foundation.org> <20080413133929.GA21007@martell.zuzino.mipt.ru> <Pine.LNX.4.64.0804141240260.7699@schroedinger.engr.sgi.com> <20080414201247.GA4763@martell.zuzino.mipt.ru>
In-Reply-To: <20080414201247.GA4763@martell.zuzino.mipt.ru>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 14, 2008 at 12:41:11PM -0700, Christoph Lameter wrote:
>> Applying Pekka's patch does not fix it? Looks like the another case of the 
>> missing slab_lock.

Alexey Dobriyan wrote:
> Sadly, no. Oops remains the same.

So you're running 2.6.25-rc8-mm2 and with the following patch:

http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.25-rc8/2.6.25-rc8-mm2/hot-fixes/slub-add-missing-slab_unlock-to-__kmem_cache_shrink.patch

Maybe I'm getting old and need glasses but I simply can't see how on 
earth you can hit the BUG_ON() in __bit_spin_unlock() in the loop...

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
