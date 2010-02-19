Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BA5C76B0047
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 00:09:36 -0500 (EST)
Received: by pzk36 with SMTP id 36so10525163pzk.23
        for <linux-mm@kvack.org>; Thu, 18 Feb 2010 21:09:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1266516162-14154-4-git-send-email-mel@csn.ul.ie>
References: <1266516162-14154-1-git-send-email-mel@csn.ul.ie>
	 <1266516162-14154-4-git-send-email-mel@csn.ul.ie>
Date: Fri, 19 Feb 2010 14:09:35 +0900
Message-ID: <28c262361002182109p67f7d221m9385b56e52b33f50@mail.gmail.com>
Subject: Re: [PATCH 03/12] mm: Share the anon_vma ref counts between KSM and
	page migration
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 19, 2010 at 3:02 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> For clarity of review, KSM and page migration have separate refcounts on
> the anon_vma. While clear, this is a waste of memory. This patch gets
> KSM and page migration to share their toys in a spirit of harmony.
>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

When I reviewed your patch [1/12], I thought like this.
Looks good to me.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
