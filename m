Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id F29756B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 12:38:04 -0400 (EDT)
Received: by mail-la0-f50.google.com with SMTP id b8so2672109lan.23
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 09:38:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id cn1si22569217wib.60.2014.06.02.09.38.02
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 09:38:03 -0700 (PDT)
Message-ID: <538ca86b.a15cb40a.56e9.78fcSMTPIN_ADDED_BROKEN@mx.google.com>
Date: Mon, 02 Jun 2014 12:37:32 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
In-Reply-To: <538CA269.6010300@intel.com>
References: <20140521193336.5df90456.akpm@linux-foundation.org>
 <1401686699-9723-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1401686699-9723-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <538CA269.6010300@intel.com>
Subject: Re: [PATCH 1/3] replace PAGECACHE_TAG_* definition with enumeration
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@intel.com
Cc: akpm@linux-foundation.org, koct9i@gmail.com, fengguang.wu@intel.com, acme@redhat.com, bp@alien8.de, kirill@shutemov.name, hannes@cmpxchg.org, rusty@rustcorp.com.au, davem@davemloft.net, andres@2ndquadrant.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jun 02, 2014 at 09:12:25AM -0700, Dave Hansen wrote:
> On 06/01/2014 10:24 PM, Naoya Horiguchi wrote:
> > -#define PAGECACHE_TAG_DIRTY	0
> > -#define PAGECACHE_TAG_WRITEBACK	1
> > -#define PAGECACHE_TAG_TOWRITE	2
> > +enum {
> > +	PAGECACHE_TAG_DIRTY,
> > +	PAGECACHE_TAG_WRITEBACK,
> > +	PAGECACHE_TAG_TOWRITE,
> > +	__NR_PAGECACHE_TAGS,
> > +};
> 
> Doesn't this end up exposing kernel-internal values out to a userspace
> interface?  Wouldn't that lock these values in to the ABI?

Yes, that would. I hope these PAGECACHE_TAG_* stuff is very basic
things and will never change drastically in the future (only added),
so it's unlikely to bother people about ABI breakage things.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
