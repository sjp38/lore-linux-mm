Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 0BA746B0035
	for <linux-mm@kvack.org>; Thu, 17 Jul 2014 07:31:00 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id q58so2581003wes.7
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 04:31:00 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.229])
        by mx.google.com with ESMTP id dz10si8211171wib.76.2014.07.17.04.30.58
        for <linux-mm@kvack.org>;
        Thu, 17 Jul 2014 04:30:59 -0700 (PDT)
Date: Thu, 17 Jul 2014 14:30:40 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v12 8/8] mm: Don't split THP page when syscall is called
Message-ID: <20140717113040.GB10127@node.dhcp.inet.fi>
References: <1404886949-17695-1-git-send-email-minchan@kernel.org>
 <1404886949-17695-9-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1404886949-17695-9-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>

On Wed, Jul 09, 2014 at 03:22:29PM +0900, Minchan Kim wrote:
> We don't need to split THP page when MADV_FREE syscall is
> called. It could be done when VM decide really frees it so
> we could avoid unnecessary THP split.
> 
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

I would like to free THP without splitting. But good enough for now.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
