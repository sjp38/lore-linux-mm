Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 92BB96B0032
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 16:32:37 -0500 (EST)
Received: by pdev10 with SMTP id v10so7703432pde.10
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 13:32:37 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id bv8si4076218pad.86.2015.02.25.13.31.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Feb 2015 13:32:11 -0800 (PST)
Date: Wed, 25 Feb 2015 13:31:40 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 4.0-rc1/PARISC: BUG: non-zero nr_pmds on freeing mm
Message-Id: <20150225133140.56cfb479cd2f4461ed4fa6d5@linux-foundation.org>
In-Reply-To: <20150225204743.GA31668@node.dhcp.inet.fi>
References: <20150224225454.GA14117@fuloong-minipc.musicnaut.iki.fi>
	<20150225202130.GA31491@node.dhcp.inet.fi>
	<20150225123048.a9c97ea726f747e029b4688a@linux-foundation.org>
	<20150225204743.GA31668@node.dhcp.inet.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Aaro Koskinen <aaro.koskinen@iki.fi>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-parisc@vger.kernel.org, linux-mm@kvack.org

On Wed, 25 Feb 2015 22:47:43 +0200 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> > > If not, I can prepare a patchset which only adds missing
> > > __PAGETABLE_PUD_FOLDED and __PAGETABLE_PMD_FOLDED.
> > 
> > Something simple would be preferred, but I don't know how much simpler
> > the above would be?
> 
> Not much simplier: __PAGETABLE_PMD_FOLDED is missing in frv, m32r, m68k,
> mn10300, parisc and s390.

I don't really know what's going on here.  Let's rewind a bit, please. 
What is the bug, what causes it, which commit caused it and why the
heck does it require a massive patchset to fix 4.0?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
