Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 99F086B00B1
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 06:41:20 -0400 (EDT)
Received: by yx-out-1718.google.com with SMTP id 36so1096408yxh.26
        for <linux-mm@kvack.org>; Wed, 22 Apr 2009 03:41:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090422100958.GB10380@csn.ul.ie>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie>
	 <1240266011-11140-21-git-send-email-mel@csn.ul.ie>
	 <20090422091456.626E.A69D9226@jp.fujitsu.com>
	 <20090422100958.GB10380@csn.ul.ie>
Date: Wed, 22 Apr 2009 19:41:58 +0900
Message-ID: <2f11576a0904220341s839b3e9m70d49dc1af27e89@mail.gmail.com>
Subject: Re: [PATCH 20/25] Do not check for compound pages during the page
	allocator sanity checks
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

>> inserting VM_BUG_ON(PageTail(page)) is better?
>>
>
> We already go one further with
>
> #define PAGE_FLAGS_CHECK_AT_PREP =A0 =A0 =A0 =A0((1 << NR_PAGEFLAGS) - 1)
>
> ...
>
> if (.... | (page->flags & PAGE_FLAGS_CHECK_AT_PREP))
> =A0 =A0 =A0 =A0bad_page(page);
>
> PG_tail is in PAGE_FLAGS_CHECK_AT_PREP so we're already checking for it
> and calling bad_page() if set.

ok, good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
