Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1B6916B0005
	for <linux-mm@kvack.org>; Sat,  3 Feb 2018 14:57:32 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id b15so11595230wrb.0
        for <linux-mm@kvack.org>; Sat, 03 Feb 2018 11:57:32 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id y71si3042261wmd.200.2018.02.03.11.57.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Feb 2018 11:57:31 -0800 (PST)
Subject: Re: [kernel-hardening] [PATCH 4/6] Protectable Memory
From: Igor Stoppa <igor.stoppa@huawei.com>
References: <20180124175631.22925-1-igor.stoppa@huawei.com>
 <20180124175631.22925-5-igor.stoppa@huawei.com>
 <CAG48ez0JRU8Nmn7jLBVoy6SMMrcj46R0_R30Lcyouc4R9igi-g@mail.gmail.com>
 <20180126053542.GA30189@bombadil.infradead.org>
 <alpine.DEB.2.20.1802021236510.31548@nuc-kabylake>
 <f2ddaed0-313e-8664-8a26-9d10b66ed0c5@huawei.com>
Message-ID: <b75b5903-0177-8ad9-5c2b-fc63438fb5f2@huawei.com>
Date: Sat, 3 Feb 2018 21:57:13 +0200
MIME-Version: 1.0
In-Reply-To: <f2ddaed0-313e-8664-8a26-9d10b66ed0c5@huawei.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>, Boris Lukashev <blukashev@sempervictus.com>
Cc: Jann Horn <jannh@google.com>, jglisse@redhat.com, Kees Cook <keescook@chromium.org>, Michal Hocko <mhocko@kernel.org>, Laura Abbott <labbott@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-security-module@vger.kernel.org, linux-mm@kvack.org, kernel list <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

>> On Thu, 25 Jan 2018, Matthew Wilcox wrote:

>>> It's worth having a discussion about whether we want the pmalloc API
>>> or whether we want a slab-based API.  
I'd love to have some feedback specifically about the API.

I have also some idea about userspace and how to extend the pmalloc
concept to it:

http://www.openwall.com/lists/kernel-hardening/2018/01/30/20

I'll be AFK intermittently for about 2 weeks, so i might not be able to
reply immediately, but from my perspective this would be just the
beginning of a broader hardening of both kernel and userspace that I'd
like to pursue.

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
