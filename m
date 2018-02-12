Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 42BD26B000A
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 08:42:19 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id s18so8894952wrg.5
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 05:42:19 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id 6si487260edn.491.2018.02.12.05.42.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Feb 2018 05:42:17 -0800 (PST)
Subject: Re: [PATCH 4/6] Protectable Memory
References: <20180211031920.3424-1-igor.stoppa@huawei.com>
 <20180211031920.3424-5-igor.stoppa@huawei.com>
 <20180211123743.GC13931@rapoport-lnx>
 <e7ea02b4-3d43-9543-3d14-61c27e155042@huawei.com>
 <20180212114310.GD20737@rapoport-lnx> <20180212125347.GE20737@rapoport-lnx>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <68edadf0-2b23-eaeb-17de-884032f0b906@huawei.com>
Date: Mon, 12 Feb 2018 15:41:57 +0200
MIME-Version: 1.0
In-Reply-To: <20180212125347.GE20737@rapoport-lnx>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: willy@infradead.org, rdunlap@infradead.org, corbet@lwn.net, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, jglisse@redhat.com, hch@infradead.org, cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com



On 12/02/18 14:53, Mike Rapoport wrote:
> 'scripts/kernel-doc -v -none 

That has a quite interesting behavior.

I run it on genalloc.c while I am in the process of adding the brackets
to the function names in the kernel-doc description.

The brackets confuse the script and it fails to output the name of the
function in the log:

lib/genalloc.c:123: info: Scanning doc for get_bitmap_entry
lib/genalloc.c:139: info: Scanning doc for
lib/genalloc.c:152: info: Scanning doc for
lib/genalloc.c:164: info: Scanning doc for


The first function does not have the brackets.
The others do. So what should I do with the missing brackets?
Add them, according to the kernel docs, or leave them out?

I'd lean toward adding them.

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
