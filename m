From: Christoph Rohland <cr@sap.com>
Subject: Re: dbench on tmpfs OOM's
References: <Pine.LNX.4.44.0209170726050.19523-100000@localhost.localdomain>
Date: Tue, 17 Sep 2002 09:57:18 +0200
In-Reply-To: <Pine.LNX.4.44.0209170726050.19523-100000@localhost.localdomain> (Hugh
 Dickins's message of "Tue, 17 Sep 2002 08:01:20 +0100 (BST)")
Message-ID: <sn092gm9.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@digeo.com>, William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Hugh,

On Tue, 17 Sep 2002, Hugh Dickins wrote:
> What I never did was try GFP_HIGHUSER and kmap on the index pages:
> I think I decided back then that it wasn't likely to be needed
> (sparsely filled file indexes are a rarer case than sparsely filled
> pagetables, once the stupidity is fixed; and small files don't use
> index pages at all).  But Bill's testing may well prove me wrong.

I think that this would be a good improvement. Big database and
application servers would definitely benefit from it, desktops could
easier use tmpfs as temporary file systems.

I never dared to do it with my limited time since I feared deadlock
situations.

Also I ended up that I would try to go one step further: Make the
index pages swappable, i.e. make the directory nodes normal tmpfs
files. This would even make the accounting right.

Greetings
		Christoph


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
