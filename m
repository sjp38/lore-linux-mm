Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 00F7A6B0003
	for <linux-mm@kvack.org>; Fri,  2 Feb 2018 13:39:25 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id q18so22061993ioh.4
        for <linux-mm@kvack.org>; Fri, 02 Feb 2018 10:39:24 -0800 (PST)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id u82si601393itb.91.2018.02.02.10.39.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Feb 2018 10:39:22 -0800 (PST)
Date: Fri, 2 Feb 2018 12:39:20 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [kernel-hardening] [PATCH 4/6] Protectable Memory
In-Reply-To: <20180126053542.GA30189@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1802021236510.31548@nuc-kabylake>
References: <20180124175631.22925-1-igor.stoppa@huawei.com> <20180124175631.22925-5-igor.stoppa@huawei.com> <CAG48ez0JRU8Nmn7jLBVoy6SMMrcj46R0_R30Lcyouc4R9igi-g@mail.gmail.com> <20180126053542.GA30189@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jann Horn <jannh@google.com>, Igor Stoppa <igor.stoppa@huawei.com>, jglisse@redhat.com, Kees Cook <keescook@chromium.org>, Michal Hocko <mhocko@kernel.org>, Laura Abbott <labbott@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-security-module@vger.kernel.org, linux-mm@kvack.org, kernel list <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Thu, 25 Jan 2018, Matthew Wilcox wrote:

> It's worth having a discussion about whether we want the pmalloc API
> or whether we want a slab-based API.  We can have a separate discussion
> about an API to remove pages from the physmap.

We could even do this in a more thorough way. Can we use a ring 1 / 2
distinction to create a hardened OS core that policies the rest of
the ever expanding kernel with all its modules and this and that feature?

I think that will long term be a better approach and allow more than the
current hardening approaches can get you. It seems that we are willing to
tolerate significant performance regressions now. So lets use the
protection mechanisms that the hardware offers.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
