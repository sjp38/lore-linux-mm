Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id A8E4F6B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 12:48:05 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id fp1so3604913pdb.38
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 09:48:05 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id pr9si16417235pbc.175.2014.06.02.09.48.04
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 09:48:04 -0700 (PDT)
Message-ID: <538CAA13.2080708@intel.com>
Date: Mon, 02 Jun 2014 09:45:07 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] replace PAGECACHE_TAG_* definition with enumeration
References: <20140521193336.5df90456.akpm@linux-foundation.org> <1401686699-9723-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1401686699-9723-2-git-send-email-n-horiguchi@ah.jp.nec.com> <538CA269.6010300@intel.com> <1401727052-f7v7kykv@n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1401727052-f7v7kykv@n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: akpm@linux-foundation.org, koct9i@gmail.com, fengguang.wu@intel.com, acme@redhat.com, bp@alien8.de, kirill@shutemov.name, hannes@cmpxchg.org, rusty@rustcorp.com.au, davem@davemloft.net, andres@2ndquadrant.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/02/2014 09:37 AM, Naoya Horiguchi wrote:
> On Mon, Jun 02, 2014 at 09:12:25AM -0700, Dave Hansen wrote:
>> > On 06/01/2014 10:24 PM, Naoya Horiguchi wrote:
>>> > > -#define PAGECACHE_TAG_DIRTY	0
>>> > > -#define PAGECACHE_TAG_WRITEBACK	1
>>> > > -#define PAGECACHE_TAG_TOWRITE	2
>>> > > +enum {
>>> > > +	PAGECACHE_TAG_DIRTY,
>>> > > +	PAGECACHE_TAG_WRITEBACK,
>>> > > +	PAGECACHE_TAG_TOWRITE,
>>> > > +	__NR_PAGECACHE_TAGS,
>>> > > +};
>> > 
>> > Doesn't this end up exposing kernel-internal values out to a userspace
>> > interface?  Wouldn't that lock these values in to the ABI?
> Yes, that would. I hope these PAGECACHE_TAG_* stuff is very basic
> things and will never change drastically in the future (only added),
> so it's unlikely to bother people about ABI breakage things.

OK, so if I'm writing a userspace program, which header do I include
pull these values in to my program?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
