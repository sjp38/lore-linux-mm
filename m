Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id AC95C6B0036
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 12:11:39 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id y13so3575216pdi.16
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 09:11:39 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id hd2si16293016pbb.196.2014.06.02.09.11.38
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 09:11:38 -0700 (PDT)
Message-ID: <538CA239.3060506@intel.com>
Date: Mon, 02 Jun 2014 09:11:37 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm: introduce fincore()
References: <20140521193336.5df90456.akpm@linux-foundation.org> <1401686699-9723-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1401686699-9723-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1401686699-9723-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Rusty Russell <rusty@rustcorp.com.au>, David Miller <davem@davemloft.net>, Andres Freund <andres@2ndquadrant.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 06/01/2014 10:24 PM, Naoya Horiguchi wrote:
> Detail about the data format being passed to userspace are explained in
> inline comment, but generally in long entry format, we can choose which
> information is extraced flexibly, so you don't have to waste memory by
> extracting unnecessary information. And with FINCORE_SKIP_HOLE flag,
> we can skip hole pages (not on memory,) which makes us avoid a flood of
> meaningless zero entries when calling on extremely large (but only few
> pages of it are loaded on memory) file.

Something similar could be useful for hugetlbfs too.  For a 1GB page,
it's pretty silly to do 2^18 entries which essentially repeat the same
data in an interface like this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
