Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 666986B025F
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 10:48:58 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id z19so12733230oia.13
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 07:48:58 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id f8si4739317oib.77.2017.08.18.07.48.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 18 Aug 2017 07:48:57 -0700 (PDT)
Subject: Re: [kernel-hardening] [RFC] memory allocations in genalloc
References: <299c22f9-2e34-36dc-a6da-22eadbc0a59d@huawei.com>
 <bea38f28-b311-dd54-9323-f90e2b157e35@redhat.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <2d087abd-1bf4-55aa-ac92-67a9b8f9d177@huawei.com>
Date: Fri, 18 Aug 2017 17:47:16 +0300
MIME-Version: 1.0
In-Reply-To: <bea38f28-b311-dd54-9323-f90e2b157e35@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>, Jes Sorensen <jes@trained-monkey.org>
Cc: Michal Hocko <mhocko@kernel.org>, James Morris <james.l.morris@oracle.com>, Jerome Glisse <jglisse@redhat.com>, Paul Moore <paul@paul-moore.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, linux-security-module@vger.kernel.org

Hi,

On 18/08/17 16:57, Laura Abbott wrote:
> Again, if you have a specific patch or
> proposal this would be easier to review.


yes, I'm preparing it and will send it out soon,
but it was somehow surprising to me that it was chosen to implement free
with the size parameter.

It made me think that I was overlooking some obvious reason behind the
choice :-S

--
thanks for answering, igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
