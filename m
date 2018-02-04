Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5E9F36B0007
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 18:03:53 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id b6so7490752plx.3
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 15:03:53 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id v11si2771917pgo.107.2018.02.04.15.03.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 04 Feb 2018 15:03:52 -0800 (PST)
Date: Sun, 4 Feb 2018 15:03:46 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 2/6] genalloc: selftest
Message-ID: <20180204230346.GA12502@bombadil.infradead.org>
References: <20180204164732.28241-1-igor.stoppa@huawei.com>
 <20180204164732.28241-3-igor.stoppa@huawei.com>
 <e05598c1-3c7c-15c6-7278-ed52ceff0acf@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e05598c1-3c7c-15c6-7278-ed52ceff0acf@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Igor Stoppa <igor.stoppa@huawei.com>, jglisse@redhat.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, hch@infradead.org, cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Sun, Feb 04, 2018 at 02:19:22PM -0800, Randy Dunlap wrote:
> > +#ifndef __GENALLOC_SELFTEST_H__
> > +#define __GENALLOC_SELFTEST_H__
> 
> Please use _LINUX_GENALLOC_SELFTEST_H_

willy@bobo:~/kernel/linux$ git grep define.*_H__$ include/linux/*.h |wc -l
98
willy@bobo:~/kernel/linux$ git grep define.*_H_$ include/linux/*.h |wc -l
110
willy@bobo:~/kernel/linux$ git grep define.*_H$ include/linux/*.h |wc -l
885

No trailing underscore is 8x as common as one trailing underscore.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
