Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2E2436B0005
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 22:37:24 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id q5so3450294pll.17
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 19:37:24 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 126si2705470pfe.390.2018.02.09.19.37.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 09 Feb 2018 19:37:22 -0800 (PST)
Date: Fri, 9 Feb 2018 19:37:14 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 5/6] Documentation for Pmalloc
Message-ID: <20180210033714.GA12711@bombadil.infradead.org>
References: <20180130151446.24698-1-igor.stoppa@huawei.com>
 <20180130151446.24698-6-igor.stoppa@huawei.com>
 <20180130100852.2213b94d@lwn.net>
 <56eb3e0d-d74d-737a-9f85-fead2c40c17c@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56eb3e0d-d74d-737a-9f85-fead2c40c17c@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: Jonathan Corbet <corbet@lwn.net>, jglisse@redhat.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, hch@infradead.org, cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Fri, Feb 02, 2018 at 05:56:29PM +0200, Igor Stoppa wrote:
> But what is the license for the documentation? It's not code, so GPL
> seems wrong. Creative commons?

I've done this as the first line of my new documentation files:

.. SPDX-License-Identifier: CC-BY-SA-4.0

I think this is the CC license that's closest in spirit to the GPL without
the unintended consequences of the GPL when used on documentation.  The
GFDL seems to be out of favour these days.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
