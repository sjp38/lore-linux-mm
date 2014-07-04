Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id D19C96B0037
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 21:43:06 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id cc10so12249609wib.0
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 18:43:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h12si26249566wic.42.2014.07.03.18.43.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jul 2014 18:43:05 -0700 (PDT)
Date: Thu, 3 Jul 2014 21:41:51 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 1/4] define PAGECACHE_TAG_* as enumeration under
 include/uapi
Message-ID: <20140704014151.GA9869@nhori>
References: <1404424335-30128-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1404424335-30128-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20140704011639.GG9508@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140704011639.GG9508@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Rusty Russell <rusty@rustcorp.com.au>, David Miller <davem@davemloft.net>, Andres Freund <andres@2ndquadrant.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, Christoph Hellwig <hch@infradead.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, Jul 04, 2014 at 11:16:39AM +1000, Dave Chinner wrote:
> On Thu, Jul 03, 2014 at 05:52:12PM -0400, Naoya Horiguchi wrote:
> > We need the pagecache tags to be exported to userspace later in this
> > series for fincore(2), so this patch moves the definition to the new
> > include file for preparation. We also use the number of pagecache tags,
> > so this patch also adds it.
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> NACK.
> 
> The radix tree tags are deeply internal implementation details.
> They are an artifact of the current mark-and-sweep writeback
> algorithm, and as such should never, ever be exposed to userspace,
> let alone fixed in an ABI we need to support forever more.

Hm, OK, so I'll do whole this series without pagecache tag things.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
