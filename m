Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 0553D6B006C
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 06:54:55 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id l2so6005883wgh.27
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 03:54:54 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id p15si2381774wiv.42.2014.12.08.03.54.54
        for <linux-mm@kvack.org>;
        Mon, 08 Dec 2014 03:54:54 -0800 (PST)
Date: Mon, 8 Dec 2014 13:54:47 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH V3] mm:add VM_BUG_ON_PAGE() for page_mapcount()
Message-ID: <20141208115447.GA29028@node.dhcp.inet.fi>
References: <010b01d012ca$05244060$0f6cc120$@alibaba-inc.com>
 <35FD53F367049845BC99AC72306C23D103E688B313F9@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E688B313FA@CNBJMBX05.corpusers.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35FD53F367049845BC99AC72306C23D103E688B313FA@CNBJMBX05.corpusers.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: 'Hillf Danton' <hillf.zj@alibaba-inc.com>, 'linux-kernel' <linux-kernel@vger.kernel.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, 'Andrew Morton' <akpm@linux-foundation.org>

On Mon, Dec 08, 2014 at 05:59:46PM +0800, Wang, Yalin wrote:
> This patch add VM_BUG_ON_PAGE() for slab page,
> because _mapcount is an union with slab struct in struct page,
> avoid access _mapcount if this page is a slab page.
> Also remove the unneeded bracket.
> 
> Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
