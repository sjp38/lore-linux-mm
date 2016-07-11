Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 06CF76B0005
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 09:30:20 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p41so16945823lfi.0
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 06:30:19 -0700 (PDT)
Received: from mail-lf0-x231.google.com (mail-lf0-x231.google.com. [2a00:1450:4010:c07::231])
        by mx.google.com with ESMTPS id l16si1927892lfi.366.2016.07.11.06.30.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jul 2016 06:30:18 -0700 (PDT)
Received: by mail-lf0-x231.google.com with SMTP id q132so73402132lfe.3
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 06:30:18 -0700 (PDT)
Date: Mon, 11 Jul 2016 16:30:15 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: a question about protection_map[]
Message-ID: <20160711133015.GA8028@node.shutemov.name>
References: <5783710E.3070602@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5783710E.3070602@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: alan@lxorguk.ukuu.org.uk, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 11, 2016 at 06:12:30PM +0800, Xishi Qiu wrote:
> Hi,
> 
> We can use mprotect to set read only or read/write.
> 
> mprotect_fixup()
> 	vma_set_page_prot()
> 		vm_pgprot_modify()
> 			vm_get_page_prot()
> 				protection_map[vm_flags & (VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)]
> 
> The following code shows that prots from __P001(PROT_READ) and __P010(PROT_WRITE)
> are the same, so how does it distinguish read only or read/write from mprotect?

It doesn't.

Write protection will be removed by fault handler on next write access to
the page. Somewhat suboptiomal, but zero page implemenation relies on this
to work properly.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
