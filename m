Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9B9A66B0008
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 06:28:40 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id s18so8725906wrg.5
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 03:28:40 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id a19si6586444wrh.422.2018.02.12.03.28.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Feb 2018 03:28:39 -0800 (PST)
Subject: Re: [PATCH 6/6] Documentation for Pmalloc
References: <20180211031920.3424-1-igor.stoppa@huawei.com>
 <20180211031920.3424-7-igor.stoppa@huawei.com>
 <20180211211741.GD4680@bombadil.infradead.org>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <f3df57c6-47af-16af-c014-27c9c33c9879@huawei.com>
Date: Mon, 12 Feb 2018 13:28:21 +0200
MIME-Version: 1.0
In-Reply-To: <20180211211741.GD4680@bombadil.infradead.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: rdunlap@infradead.org, corbet@lwn.net, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, jglisse@redhat.com, hch@infradead.org, cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com



On 11/02/18 23:17, Matthew Wilcox wrote:
> On Sun, Feb 11, 2018 at 05:19:20AM +0200, Igor Stoppa wrote:
>> @@ -0,0 +1,114 @@
>> +SPDX-License-Identifier: CC-BY-SA-4.0
> 
> You need the '.. ' before the 'SPDX'.  See
> Documentation/process/license-rules.rst

yes, sorry, I thought I had understood how it works,
but clearly I hadn't :-(

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
