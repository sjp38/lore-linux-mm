Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id A7AB76B0037
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 14:48:56 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id a108so11207165qge.36
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 11:48:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id s49si18741954qgs.97.2014.06.02.11.48.55
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 11:48:55 -0700 (PDT)
Message-ID: <538cc717.34268c0a.125c.ffffbfdbSMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/3] replace PAGECACHE_TAG_* definition with enumeration
Date: Mon,  2 Jun 2014 14:48:19 -0400
In-Reply-To: <538CC026.4030008@intel.com>
References: <20140521193336.5df90456.akpm@linux-foundation.org> <1401686699-9723-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1401686699-9723-2-git-send-email-n-horiguchi@ah.jp.nec.com> <538CA269.6010300@intel.com> <1401727052-f7v7kykv@n-horiguchi@ah.jp.nec.com> <538CAA13.2080708@intel.com> <538cb12a.8518c20a.1a51.ffff9761SMTPIN_ADDED_BROKEN@mx.google.com> <538CC026.4030008@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Rusty Russell <rusty@rustcorp.com.au>, David Miller <davem@davemloft.net>, Andres Freund <andres@2ndquadrant.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jun 02, 2014 at 11:19:18AM -0700, Dave Hansen wrote:
> On 06/02/2014 10:14 AM, Naoya Horiguchi wrote:
> > Yes, that's necessary to consider (but I haven't done, sorry),
> > so I'm thinking of moving this definition to the new file
> > include/uapi/linux/pagecache.h and let it be imported from the
> > userspace programs. Is it fine?
> 
> Yep, although I'd probably also explicitly separate the definitions of
> the user-exposed ones from the kernel-internal ones.  We want to make
> this hard to screw up.
> 
> I can see why we might want to expose dirty and writeback out to
> userspace, especially since we already expose the aggregate, system-wide
> view in /proc/meminfo.  But, what about PAGECACHE_TAG_TOWRITE?  I really
> can't think of a good reason why userspace would ever care about it or
> consider it different from PAGECACHE_TAG_DIRTY.

I guess that TOWRITE tag might be useful to predict IO behavior
("which pages are to be writeback next" type of information).
But it's not clear to me how. I hope that DB developers have some
idea about good usecases of this tag for userspace.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
