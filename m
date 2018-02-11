Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1E8FC6B000C
	for <linux-mm@kvack.org>; Sat, 10 Feb 2018 21:01:46 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r82so1027117wme.0
        for <linux-mm@kvack.org>; Sat, 10 Feb 2018 18:01:46 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id z12si2261492edm.176.2018.02.10.18.01.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Feb 2018 18:01:44 -0800 (PST)
Subject: Re: [PATCH 2/6] genalloc: selftest
References: <20180204164732.28241-3-igor.stoppa@huawei.com>
 <201802080423.jTtuTsUK%fengguang.wu@intel.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <78f8d652-220f-05e9-ed69-39108517531c@huawei.com>
Date: Sun, 11 Feb 2018 04:01:25 +0200
MIME-Version: 1.0
In-Reply-To: <201802080423.jTtuTsUK%fengguang.wu@intel.com>
Content-Type: text/plain; charset="windows-1252"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, jglisse@redhat.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, hch@infradead.org, willy@infradead.org, cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com



On 07/02/18 22:25, kbuild test robot wrote:

[...]

>>> lib/genalloc-selftest.c:17:10: fatal error: asm/set_memory.h: No such file or directory
>     #include <asm/set_memory.h>

This header is unnecessary and will be removed.

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
