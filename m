Date: Wed, 2 Nov 2005 20:45:03 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: New bug in patch and existing Linux code - race with install_page()
 (was: Re: [PATCH] 2.6.14 patch for supporting madvise(MADV_REMOVE))
In-Reply-To: <Pine.LNX.4.61.0511022003070.17607@goblin.wat.veritas.com>
Message-ID: <Pine.LNX.4.61.0511022043240.17907@goblin.wat.veritas.com>
References: <1130366995.23729.38.camel@localhost.localdomain>
 <20051102014321.GG24051@opteron.random> <1130947957.24503.70.camel@localhost.localdomain>
 <200511022054.15119.blaisorblade@yahoo.it> <Pine.LNX.4.61.0511022003070.17607@goblin.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Blaisorblade <blaisorblade@yahoo.it>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Andrea Arcangeli <andrea@suse.de>, lkml <linux-kernel@vger.kernel.org>, akpm@osdl.org, dvhltc@us.ibm.com, linux-mm <linux-mm@kvack.org>, Jeff Dike <jdike@addtoit.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2 Nov 2005, Hugh Dickins wrote:
> On Wed, 2 Nov 2005, Blaisorblade wrote:
> 
> No, it should be fine as is (unless perhaps some barrier is needed).

We already have the barrier needed: we're holding page_table_lock (pte lock).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
