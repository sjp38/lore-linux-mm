Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4F6AE680FF1
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 10:42:40 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 80so27211781pfy.2
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 07:42:40 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id y9si7247135pge.356.2017.02.16.07.42.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Feb 2017 07:42:39 -0800 (PST)
Subject: Re: [PATCH] mm,x86: fix SMP x86 32bit build for native_pud_clear()
References: <148719066814.31111.3239231168815337012.stgit@djiang5-desk3.ch.intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <68216ac2-e194-30fa-9dcb-2020e8953bf5@linux.intel.com>
Date: Thu, 16 Feb 2017 07:42:34 -0800
MIME-Version: 1.0
In-Reply-To: <148719066814.31111.3239231168815337012.stgit@djiang5-desk3.ch.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jiang <dave.jiang@intel.com>, akpm@linux-foundation.org
Cc: keescook@google.com, mawilcox@microsoft.com, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, jack@suse.com, dan.j.williams@intel.com, linux-ext4@vger.kernel.org, ross.zwisler@linux.intel.com, vbabka@suse.cz, alexander.kapshuk@gmail.com

On 02/15/2017 12:31 PM, Dave Jiang wrote:
> The fix introduced by e4decc90 to fix the UP case for 32bit x86, however
> that broke the SMP case that was working previously. Add ifdef so the dummy
> function only show up for 32bit UP case only.

Could you elaborate a bit on how it broke things?

> Fix: e4decc90 mm,x86: native_pud_clear missing on i386 build

Which tree is that in, btw?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
