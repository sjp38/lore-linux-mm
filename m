Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id A5B236B0035
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 21:16:46 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so1090627pad.35
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 18:16:45 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id pi1si34139295pbb.62.2014.07.03.18.16.42
        for <linux-mm@kvack.org>;
        Thu, 03 Jul 2014 18:16:44 -0700 (PDT)
Date: Fri, 4 Jul 2014 11:16:39 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 1/4] define PAGECACHE_TAG_* as enumeration under
 include/uapi
Message-ID: <20140704011639.GG9508@dastard>
References: <1404424335-30128-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1404424335-30128-2-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1404424335-30128-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Rusty Russell <rusty@rustcorp.com.au>, David Miller <davem@davemloft.net>, Andres Freund <andres@2ndquadrant.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, Christoph Hellwig <hch@infradead.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, Jul 03, 2014 at 05:52:12PM -0400, Naoya Horiguchi wrote:
> We need the pagecache tags to be exported to userspace later in this
> series for fincore(2), so this patch moves the definition to the new
> include file for preparation. We also use the number of pagecache tags,
> so this patch also adds it.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

NACK.

The radix tree tags are deeply internal implementation details.
They are an artifact of the current mark-and-sweep writeback
algorithm, and as such should never, ever be exposed to userspace,
let alone fixed in an ABI we need to support forever more.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
