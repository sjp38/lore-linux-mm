Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id 74DF66B0038
	for <linux-mm@kvack.org>; Mon, 18 Aug 2014 22:11:04 -0400 (EDT)
Received: by mail-qa0-f48.google.com with SMTP id m5so5090235qaj.7
        for <linux-mm@kvack.org>; Mon, 18 Aug 2014 19:11:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o90si26931944qgd.76.2014.08.18.19.11.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Aug 2014 19:11:03 -0700 (PDT)
Message-ID: <53F2B221.5070107@redhat.com>
Date: Mon, 18 Aug 2014 22:10:41 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v15 7/7] mm: Don't split THP page when syscall is called
References: <1408321076-2231-1-git-send-email-minchan@kernel.org> <1408321076-2231-8-git-send-email-minchan@kernel.org>
In-Reply-To: <1408321076-2231-8-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, zhangyanfei@cn.fujitsu.com, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 08/17/2014 08:17 PM, Minchan Kim wrote:
> We don't need to split THP page when MADV_FREE syscall is
> called. It could be done when VM decide really frees it so
> we could avoid unnecessary THP split.
>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
