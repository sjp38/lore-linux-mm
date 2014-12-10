Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1D9D66B0032
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 06:06:15 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id bs8so12913240wib.3
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 03:06:14 -0800 (PST)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id hm5si6956045wjc.56.2014.12.10.03.06.14
        for <linux-mm@kvack.org>;
        Wed, 10 Dec 2014 03:06:14 -0800 (PST)
Date: Wed, 10 Dec 2014 13:05:56 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC] mm:fix zero_page huge_zero_page rss/pss statistic
Message-ID: <20141210110556.GA10630@node.dhcp.inet.fi>
References: <35FD53F367049845BC99AC72306C23D103E688B313EE@CNBJMBX05.corpusers.net>
 <CALYGNiOuBKz8shHSrFCp0BT5AV6XkNOCHj+LJedQQ-2YdZtM7w@mail.gmail.com>
 <35FD53F367049845BC99AC72306C23D103E688B313F2@CNBJMBX05.corpusers.net>
 <20141205143134.37139da2208c654a0d3cd942@linux-foundation.org>
 <35FD53F367049845BC99AC72306C23D103E688B313F4@CNBJMBX05.corpusers.net>
 <20141208114601.GA28846@node.dhcp.inet.fi>
 <35FD53F367049845BC99AC72306C23D103E688B313FB@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E688B31403@CNBJMBX05.corpusers.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35FD53F367049845BC99AC72306C23D103E688B31403@CNBJMBX05.corpusers.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Konstantin Khlebnikov' <koct9i@gmail.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'n-horiguchi@ah.jp.nec.com'" <n-horiguchi@ah.jp.nec.com>, "'oleg@redhat.com'" <oleg@redhat.com>, "'gorcunov@openvz.org'" <gorcunov@openvz.org>, "'pfeiner@google.com'" <pfeiner@google.com>

On Wed, Dec 10, 2014 at 03:22:21PM +0800, Wang, Yalin wrote:
> smaps_pte_entry() doesn't ignore zero_huge_page,
> but it ignore zero_page, because vm_normal_page() will
> ignore it. We remove vm_normal_page() call, because walk_page_range()
> have ignore VM_PFNMAP vma maps, it's safe to just use pfn_valid(),
> so that we can also consider zero_page to be a valid page.

We fixed huge zero page accounting in smaps recentely. See mm tree.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
