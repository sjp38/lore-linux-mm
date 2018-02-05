Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 167676B000D
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 22:45:42 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id 36so10290309plb.18
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 19:45:42 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id r18si3092898pgv.485.2018.02.04.19.45.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 04 Feb 2018 19:45:40 -0800 (PST)
Date: Sun, 4 Feb 2018 19:45:31 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/6] genalloc: track beginning of allocations
Message-ID: <20180205034531.GA18559@bombadil.infradead.org>
References: <20180204164732.28241-1-igor.stoppa@huawei.com>
 <20180204164732.28241-2-igor.stoppa@huawei.com>
 <60e66c5a-c1de-246f-4be8-b02cb0275da6@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <60e66c5a-c1de-246f-4be8-b02cb0275da6@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Igor Stoppa <igor.stoppa@huawei.com>, jglisse@redhat.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, hch@infradead.org, cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Sun, Feb 04, 2018 at 02:34:08PM -0800, Randy Dunlap wrote:
> > +/**
> > + * cleart_bits_ll - according to the mask, clears the bits specified by
> 
>       clear_bits_ll

'make W=1' should catch this ... yes?

(hint: building with 'make C=1 W=1' finds all kinds of interesting issues
in your code.  W=12 or W=123 finds too many false positives for my tastes)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
