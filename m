Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 214486B0003
	for <linux-mm@kvack.org>; Sun, 11 Feb 2018 16:18:06 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 30so7821670wrw.6
        for <linux-mm@kvack.org>; Sun, 11 Feb 2018 13:18:06 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:8b0:10b:1236::1])
        by mx.google.com with ESMTPS id r1si5386658wre.17.2018.02.11.13.18.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 11 Feb 2018 13:18:04 -0800 (PST)
Date: Sun, 11 Feb 2018 13:17:41 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 6/6] Documentation for Pmalloc
Message-ID: <20180211211741.GD4680@bombadil.infradead.org>
References: <20180211031920.3424-1-igor.stoppa@huawei.com>
 <20180211031920.3424-7-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180211031920.3424-7-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: rdunlap@infradead.org, corbet@lwn.net, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, jglisse@redhat.com, hch@infradead.org, cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Sun, Feb 11, 2018 at 05:19:20AM +0200, Igor Stoppa wrote:
> @@ -0,0 +1,114 @@
> +SPDX-License-Identifier: CC-BY-SA-4.0

You need the '.. ' before the 'SPDX'.  See
Documentation/process/license-rules.rst

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
