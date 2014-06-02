Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id E22136B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 14:19:36 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id ld10so4469660pab.34
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 11:19:36 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id gq8si16776022pbc.50.2014.06.02.11.19.35
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 11:19:35 -0700 (PDT)
Message-ID: <538CC026.4030008@intel.com>
Date: Mon, 02 Jun 2014 11:19:18 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] replace PAGECACHE_TAG_* definition with enumeration
References: <20140521193336.5df90456.akpm@linux-foundation.org> <1401686699-9723-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1401686699-9723-2-git-send-email-n-horiguchi@ah.jp.nec.com> <538CA269.6010300@intel.com> <1401727052-f7v7kykv@n-horiguchi@ah.jp.nec.com> <538CAA13.2080708@intel.com> <538cb12a.8518c20a.1a51.ffff9761SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <538cb12a.8518c20a.1a51.ffff9761SMTPIN_ADDED_BROKEN@mx.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Rusty Russell <rusty@rustcorp.com.au>, David Miller <davem@davemloft.net>, Andres Freund <andres@2ndquadrant.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/02/2014 10:14 AM, Naoya Horiguchi wrote:
> Yes, that's necessary to consider (but I haven't done, sorry),
> so I'm thinking of moving this definition to the new file
> include/uapi/linux/pagecache.h and let it be imported from the
> userspace programs. Is it fine?

Yep, although I'd probably also explicitly separate the definitions of
the user-exposed ones from the kernel-internal ones.  We want to make
this hard to screw up.

I can see why we might want to expose dirty and writeback out to
userspace, especially since we already expose the aggregate, system-wide
view in /proc/meminfo.  But, what about PAGECACHE_TAG_TOWRITE?  I really
can't think of a good reason why userspace would ever care about it or
consider it different from PAGECACHE_TAG_DIRTY.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
