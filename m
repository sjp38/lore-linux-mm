Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f49.google.com (mail-yh0-f49.google.com [209.85.213.49])
	by kanga.kvack.org (Postfix) with ESMTP id 105F96B0037
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 15:09:18 -0500 (EST)
Received: by mail-yh0-f49.google.com with SMTP id z20so9239279yhz.36
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 12:09:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id a4si17572766qar.172.2013.12.02.12.09.16
        for <linux-mm@kvack.org>;
        Mon, 02 Dec 2013 12:09:17 -0800 (PST)
Date: Mon, 02 Dec 2013 15:09:10 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1386014950-gms49gpt-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1385624926-28883-3-git-send-email-iamjoonsoo.kim@lge.com>
References: <1385624926-28883-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1385624926-28883-3-git-send-email-iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/9] mm/rmap: factor nonlinear handling out of
 try_to_unmap_file()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

On Thu, Nov 28, 2013 at 04:48:39PM +0900, Joonsoo Kim wrote:
> To merge all kinds of rmap traverse functions, try_to_unmap(),
> try_to_munlock(), page_referenced() and page_mkclean(), we need to
> extract common parts and separate out non-common parts.
> 
> Nonlinear handling is handled just in try_to_unmap_file() and other
> rmap traverse functions doesn't care of it. Therfore it is better
> to factor nonlinear handling out of try_to_unmap_file() in order to
> merge all kinds of rmap traverse functions easily.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
