Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id BAFC56B0035
	for <linux-mm@kvack.org>; Fri,  4 Jul 2014 06:13:12 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id g10so1762659pdj.28
        for <linux-mm@kvack.org>; Fri, 04 Jul 2014 03:13:12 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id xx7si35025395pac.35.2014.07.04.03.13.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jul 2014 03:13:11 -0700 (PDT)
Date: Fri, 4 Jul 2014 03:12:30 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 2/4] mm: introduce fincore()
Message-ID: <20140704101230.GA24688@infradead.org>
References: <1404424335-30128-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1404424335-30128-3-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1404424335-30128-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Rusty Russell <rusty@rustcorp.com.au>, David Miller <davem@davemloft.net>, Andres Freund <andres@2ndquadrant.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, Christoph Hellwig <hch@infradead.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, Jul 03, 2014 at 05:52:13PM -0400, Naoya Horiguchi wrote:
> This patch provides a new system call fincore(2), which provides mincore()-
> like information, i.e. page residency of a given file. But unlike mincore(),
> fincore() has a mode flag which allows us to extract detailed information
> about page cache like pfn and page flag. This kind of information is very
> helpful, for example when applications want to know the file cache status
> to control the IO on their own way.

It's still a nasty multiplexer for multiple different reporting formats
in a single system call.  How about your really just do a fincore that
mirrors mincore instead of piggybacking exports of various internal
flags (tags and page flags onto it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
