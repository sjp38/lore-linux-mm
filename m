Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 39D516B0005
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 08:45:55 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id r6so1106290wrg.17
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 05:45:55 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id 19si1603156wmv.97.2018.02.09.05.45.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 05:45:54 -0800 (PST)
Subject: Re: [PATCH 3/6] struct page: add field for vm_struct
References: <20180130151446.24698-1-igor.stoppa@huawei.com>
 <20180130151446.24698-4-igor.stoppa@huawei.com>
 <20180206123735.GA6151@bombadil.infradead.org>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <822b2358-4c62-b832-01f4-84756b1f02b0@huawei.com>
Date: Fri, 9 Feb 2018 15:45:38 +0200
MIME-Version: 1.0
In-Reply-To: <20180206123735.GA6151@bombadil.infradead.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: jglisse@redhat.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, hch@infradead.org, cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On 06/02/18 14:37, Matthew Wilcox wrote:

[...]

> LOCAL variable names should be short, and to the point.

[...]

> (Documentation/process/coding-style.rst)

ok, will do, thanks for the pointer!

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
