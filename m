Date: Wed, 31 Jan 2007 19:14:09 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] simplify shmem_aops.set_page_dirty method
In-Reply-To: <Pine.LNX.4.64.0701311648450.28314@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0701311906080.19136@blonde.wat.veritas.com>
References: <b040c32a0701302006y429dc981u980bee08f6a42854@mail.gmail.com>
 <Pine.LNX.4.64.0701311648450.28314@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 31 Jan 2007, Hugh Dickins wrote:
> in my patch the equivalent function did nothing beyond SetPageDirty
> (your TestSetPageDirty looks better, less redirtying the cacheline).

You've probably been wondering what I meant by that cacheline remark:
I was fantasizing TestSetPageDirty(page) as
	if (PageDirty(page))
		return 1;
	SetPageDirty(page);
	return 0;
whereas of course it's something atomic.  Perhaps I had a point,
and the less atomic version above is advantageous here: not sure.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
