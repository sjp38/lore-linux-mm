Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6B70A6B04B3
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 11:19:00 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v88so25169051wrb.1
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 08:19:00 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id 61si7977716wrs.352.2017.07.10.08.18.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Jul 2017 08:18:59 -0700 (PDT)
Subject: Re: [PATCH 1/3] Protectable memory support
References: <20170705134628.3803-1-igor.stoppa@huawei.com>
 <20170705134628.3803-2-igor.stoppa@huawei.com>
 <20170706162742.GA2919@redhat.com>
 <1665fd00-5908-2399-577d-1972c7d1c63b@huawei.com>
 <20170707184843.GA3113@redhat.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <774d9fc1-4caf-a6c9-3693-a90b5b954645@huawei.com>
Date: Mon, 10 Jul 2017 18:15:53 +0300
MIME-Version: 1.0
In-Reply-To: <20170707184843.GA3113@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: keescook@chromium.org, mhocko@kernel.org, jmorris@namei.org, labbott@redhat.com, hch@infradead.org, penguin-kernel@I-love.SAKURA.ne.jp, paul@paul-moore.com, sds@tycho.nsa.gov, casey@schaufler-ca.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On 07/07/17 21:48, Jerome Glisse wrote:

> I believe there is enough unuse field that for vmalloc pages that
> you should find one you can use. Just add some documentation in
> mm_types.h so people are aware of alternate use for the field you
> are using.


I ended up using page->private and the corresponding bit.
Because page-private is an opaque field, specifically reserved for the
allocator, I think it should not be necessary to modify mm_types.h

The reworked patch is here:
https://marc.info/?l=linux-mm&m=149969928920772&w=2

--
thanks, igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
