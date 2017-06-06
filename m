Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id A27C46B03AB
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 07:35:49 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id a7so11847984vke.12
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 04:35:49 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id b9si271278uag.189.2017.06.06.04.35.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Jun 2017 04:35:48 -0700 (PDT)
Subject: Re: [PATCH 2/5] Protectable Memory Allocator
References: <20170605192216.21596-1-igor.stoppa@huawei.com>
 <20170605192216.21596-3-igor.stoppa@huawei.com>
 <201706060444.v564iWds024768@www262.sakura.ne.jp>
 <20170606062505.GA18315@infradead.org>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <214229a9-6e64-7351-1609-79c83d75d8c9@huawei.com>
Date: Tue, 6 Jun 2017 14:34:04 +0300
MIME-Version: 1.0
In-Reply-To: <20170606062505.GA18315@infradead.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: keescook@chromium.org, mhocko@kernel.org, jmorris@namei.org, paul@paul-moore.com, sds@tycho.nsa.gov, casey@schaufler-ca.com, labbott@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On 06/06/17 09:25, Christoph Hellwig wrote:
> On Tue, Jun 06, 2017 at 01:44:32PM +0900, Tetsuo Handa wrote:

[..]

>> As far as I know, not all CONFIG_MMU=y architectures provide
>> set_memory_ro()/set_memory_rw(). You need to provide fallback for
>> architectures which do not provide set_memory_ro()/set_memory_rw()
>> or kernels built with CONFIG_MMU=n.
> 
> I think we'll just need to generalize CONFIG_STRICT_MODULE_RWX and/or
> ARCH_HAS_STRICT_MODULE_RWX so there is a symbol to key this off.

Would STRICT_KERNEL_RWX work? It's already present.
If both kernel text and rodata can be protected, so can pmalloc data.

---
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
