Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 03C636B0006
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 07:01:48 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 62so1256622wrg.0
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 04:01:47 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id m25si1768505edb.219.2018.02.21.04.01.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Feb 2018 04:01:46 -0800 (PST)
Subject: Re: [PATCH 3/6] struct page: add field for vm_struct
References: <20180211031920.3424-1-igor.stoppa@huawei.com>
 <20180211031920.3424-4-igor.stoppa@huawei.com>
 <20180211211646.GC4680@bombadil.infradead.org>
 <cef01110-dc23-4442-f277-88d1d3662e00@huawei.com>
 <b59546a4-5a5b-ca48-3b51-09440b6a5493@huawei.com>
 <20180220205442.GA15973@bombadil.infradead.org>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <c4c805ed-5869-81c2-4c05-cf53bfbef168@huawei.com>
Date: Wed, 21 Feb 2018 14:01:20 +0200
MIME-Version: 1.0
In-Reply-To: <20180220205442.GA15973@bombadil.infradead.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: rdunlap@infradead.org, corbet@lwn.net, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, jglisse@redhat.com, hch@infradead.org, cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com



On 20/02/18 22:54, Matthew Wilcox wrote:
> On Tue, Feb 20, 2018 at 09:53:30PM +0200, Igor Stoppa wrote:

[...]

>> It was found while testing on a configuration with framebuffer.
> 
> ... ah.  You tried to use vmalloc_to_page() on something which wasn't
> backed by a struct page.  That's *supposed* to return NULL, but my
> guess is that after this patch it returned garbage.

it seems to return garbage also without this patch, but I need to clean
up the code, try it again and possibly come up with a demo patch for
triggering the problem.

I'll investigate it more. However it doesn't seem to be related to the
functionality I need. So I plan to treat it as separate issue and leave
find_vm_area untouched, at least in pmalloc scope.

--
igor



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
