Message-Id: <6.0.0.20.2.20070914162337.037e82e0@172.19.0.2>
Date: Fri, 14 Sep 2007 16:42:01 +0900
From: Hisashi Hifumi <hifumi.hisashi@oss.ntt.co.jp>
Subject: Re: [PATCH] mm: use pagevec to rotate reclaimable page
In-Reply-To: <20070913193711.ecc825f7.akpm@linux-foundation.org>
References: <6.0.0.20.2.20070907113025.024dfbb8@172.19.0.2>
 <20070913193711.ecc825f7.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Thank you for your comment.

At 11:37 07/09/14, Andrew Morton wrote:

 >The page_count() test here is a bit of a worry, too.  Why do we need it?
 >The caller must have pinned the page in some fashion else we couldn't use
 >it safely in this function at all.
 >
 >I assume that you discovered that once we've cleared PageWriteback(), the
 >page can get reclaimed elsewhere?  If so, that could still happen
 >immediately after the page_count() test.  It's all a bit of a worry.
 >Deferring the ClearPageWriteback() will fix any race concerns, but I do
 >think that we need to take a ref on the page for the pagevec ownership.
 >

Actually, I considered taking a ref to pin pages. But this could prevent 
the page
reclaiming activity so I did not use it.

I reflect your comment and send you modified patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
