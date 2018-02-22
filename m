Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 590C46B02E2
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 09:20:55 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id g13so3540578wrh.23
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 06:20:55 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id 123si305101wmo.252.2018.02.22.06.20.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Feb 2018 06:20:53 -0800 (PST)
Subject: Re: [PATCH 3/6] struct page: add field for vm_struct
From: Igor Stoppa <igor.stoppa@huawei.com>
References: <20180211031920.3424-1-igor.stoppa@huawei.com>
 <20180211031920.3424-4-igor.stoppa@huawei.com>
 <20180211211646.GC4680@bombadil.infradead.org>
 <cef01110-dc23-4442-f277-88d1d3662e00@huawei.com>
 <b59546a4-5a5b-ca48-3b51-09440b6a5493@huawei.com>
 <20180220205442.GA15973@bombadil.infradead.org>
 <c4c805ed-5869-81c2-4c05-cf53bfbef168@huawei.com>
Message-ID: <bc62d1e7-96ec-d8c5-3149-9dd1922555e4@huawei.com>
Date: Thu, 22 Feb 2018 16:20:23 +0200
MIME-Version: 1.0
In-Reply-To: <c4c805ed-5869-81c2-4c05-cf53bfbef168@huawei.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: rdunlap@infradead.org, corbet@lwn.net, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, jglisse@redhat.com, hch@infradead.org, cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On 21/02/18 14:01, Igor Stoppa wrote:

> it seems to return garbage also without this patch, but I need to clean
> up the code, try it again and possibly come up with a demo patch for
> triggering the problem.
> 
> I'll investigate it more. However it doesn't seem to be related to the
> functionality I need. So I plan to treat it as separate issue and leave
> find_vm_area untouched, at least in pmalloc scope.


Follow-up:

https://lkml.org/lkml/2018/2/22/427

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
