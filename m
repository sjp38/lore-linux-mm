Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id E2B256B006C
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 06:46:14 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id bs8so6854996wib.3
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 03:46:14 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id t2si9377619wiw.60.2014.12.08.03.46.13
        for <linux-mm@kvack.org>;
        Mon, 08 Dec 2014 03:46:14 -0800 (PST)
Date: Mon, 8 Dec 2014 13:46:01 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC V4] mm:add KPF_ZERO_PAGE flag for /proc/kpageflags
Message-ID: <20141208114601.GA28846@node.dhcp.inet.fi>
References: <35FD53F367049845BC99AC72306C23D103E688B313EE@CNBJMBX05.corpusers.net>
 <CALYGNiOuBKz8shHSrFCp0BT5AV6XkNOCHj+LJedQQ-2YdZtM7w@mail.gmail.com>
 <35FD53F367049845BC99AC72306C23D103E688B313F2@CNBJMBX05.corpusers.net>
 <20141205143134.37139da2208c654a0d3cd942@linux-foundation.org>
 <35FD53F367049845BC99AC72306C23D103E688B313F4@CNBJMBX05.corpusers.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35FD53F367049845BC99AC72306C23D103E688B313F4@CNBJMBX05.corpusers.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Konstantin Khlebnikov' <koct9i@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>

On Mon, Dec 08, 2014 at 10:00:50AM +0800, Wang, Yalin wrote:
> This patch add KPF_ZERO_PAGE flag for zero_page,
> so that userspace process can notice zero_page from
> /proc/kpageflags, and then do memory analysis more accurately.
> 
> Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
> ---
>  Documentation/vm/pagemap.txt           |  5 +++++
>  fs/proc/page.c                         | 16 +++++++++++++---
>  include/linux/huge_mm.h                | 12 ++++++++++++
>  include/uapi/linux/kernel-page-flags.h |  1 +
>  mm/huge_memory.c                       |  7 +------
>  5 files changed, 32 insertions(+), 9 deletions(-)
> 
> diff --git a/Documentation/vm/pagemap.txt b/Documentation/vm/pagemap.txt
> index 5948e45..fdeb06e 100644
> --- a/Documentation/vm/pagemap.txt
> +++ b/Documentation/vm/pagemap.txt
> @@ -62,6 +62,8 @@ There are three components to pagemap:
>      20. NOPAGE
>      21. KSM
>      22. THP
> +    23. BALLOON
> +    24. ZERO_PAGE
>  
>  Short descriptions to the page flags:
>  
> @@ -102,6 +104,9 @@ Short descriptions to the page flags:
>  22. THP
>      contiguous pages which construct transparent hugepages
>  
> +24. ZERO_PAGE
> +    zero page for pfn_zero or huge_zero page
> +
>      [IO related page flags]
>   1. ERROR     IO error occurred
>   3. UPTODATE  page has up-to-date data

Would be nice to document BALLOON while you're there.
Otherwise looks good to me.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
