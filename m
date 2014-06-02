Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id BCA7A6B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 13:15:23 -0400 (EDT)
Received: by mail-wg0-f42.google.com with SMTP id y10so5368329wgg.25
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 10:15:23 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id u5si26683649wjf.58.2014.06.02.10.15.21
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 10:15:22 -0700 (PDT)
Message-ID: <538cb12a.8518c20a.1a51.ffff9761SMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/3] replace PAGECACHE_TAG_* definition with enumeration
Date: Mon,  2 Jun 2014 13:14:48 -0400
In-Reply-To: <538CAA13.2080708@intel.com>
References: <20140521193336.5df90456.akpm@linux-foundation.org> <1401686699-9723-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1401686699-9723-2-git-send-email-n-horiguchi@ah.jp.nec.com> <538CA269.6010300@intel.com> <1401727052-f7v7kykv@n-horiguchi@ah.jp.nec.com> <538CAA13.2080708@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Rusty Russell <rusty@rustcorp.com.au>, David Miller <davem@davemloft.net>, Andres Freund <andres@2ndquadrant.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jun 02, 2014 at 09:45:07AM -0700, Dave Hansen wrote:
> On 06/02/2014 09:37 AM, Naoya Horiguchi wrote:
> > On Mon, Jun 02, 2014 at 09:12:25AM -0700, Dave Hansen wrote:
> >> > On 06/01/2014 10:24 PM, Naoya Horiguchi wrote:
> >>> > > -#define PAGECACHE_TAG_DIRTY	0
> >>> > > -#define PAGECACHE_TAG_WRITEBACK	1
> >>> > > -#define PAGECACHE_TAG_TOWRITE	2
> >>> > > +enum {
> >>> > > +	PAGECACHE_TAG_DIRTY,
> >>> > > +	PAGECACHE_TAG_WRITEBACK,
> >>> > > +	PAGECACHE_TAG_TOWRITE,
> >>> > > +	__NR_PAGECACHE_TAGS,
> >>> > > +};
> >> > 
> >> > Doesn't this end up exposing kernel-internal values out to a userspace
> >> > interface?  Wouldn't that lock these values in to the ABI?
> > Yes, that would. I hope these PAGECACHE_TAG_* stuff is very basic
> > things and will never change drastically in the future (only added),
> > so it's unlikely to bother people about ABI breakage things.
> 
> OK, so if I'm writing a userspace program, which header do I include
> pull these values in to my program?

Yes, that's necessary to consider (but I haven't done, sorry),
so I'm thinking of moving this definition to the new file
include/uapi/linux/pagecache.h and let it be imported from the
userspace programs. Is it fine?

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
