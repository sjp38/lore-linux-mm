Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 587386B0038
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 12:12:28 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id bj1so1304563pad.15
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 09:12:28 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id gq7si16537964pac.237.2014.06.02.09.12.27
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 09:12:27 -0700 (PDT)
Message-ID: <538CA269.6010300@intel.com>
Date: Mon, 02 Jun 2014 09:12:25 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] replace PAGECACHE_TAG_* definition with enumeration
References: <20140521193336.5df90456.akpm@linux-foundation.org> <1401686699-9723-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1401686699-9723-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1401686699-9723-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Rusty Russell <rusty@rustcorp.com.au>, David Miller <davem@davemloft.net>, Andres Freund <andres@2ndquadrant.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/01/2014 10:24 PM, Naoya Horiguchi wrote:
> -#define PAGECACHE_TAG_DIRTY	0
> -#define PAGECACHE_TAG_WRITEBACK	1
> -#define PAGECACHE_TAG_TOWRITE	2
> +enum {
> +	PAGECACHE_TAG_DIRTY,
> +	PAGECACHE_TAG_WRITEBACK,
> +	PAGECACHE_TAG_TOWRITE,
> +	__NR_PAGECACHE_TAGS,
> +};

Doesn't this end up exposing kernel-internal values out to a userspace
interface?  Wouldn't that lock these values in to the ABI?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
