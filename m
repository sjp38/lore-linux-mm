From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH] swap-prefetch, fix lru_cache_add_tail()
Date: Thu, 18 May 2006 16:39:53 +1000
References: <1147884867.22400.9.camel@lappy>
In-Reply-To: <1147884867.22400.9.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200605181639.53546.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thursday 18 May 2006 02:54, Peter Zijlstra wrote:
> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
>
> lru_cache_add_tail() uses the inactive per-cpu pagevec. This causes
> normal inactive and intactive tail inserts to end up on the wrong end
> of the list.
>
> When the pagevec is completed by lru_cache_add_tail() but still contains
> normal inactive pages, all pages will be added to the inactive tail and
> vice versa.
>
> Also *add_drain*() will always complete to the inactive head.
>
> Add a third per-cpu pagevec to alleviate this problem.

Thanks!

> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

Signed-off-by: Con Kolivas <kernel@kolivas.org>

-- 
-ck

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
