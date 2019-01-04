Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6E06F8E00F9
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 13:34:47 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id p3so27668922plk.9
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 10:34:47 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id o3si54924341pgm.441.2019.01.04.10.34.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 10:34:46 -0800 (PST)
Subject: Re: [RFC PATCH 3/3] selftests/vm: add script helper for
 CONFIG_TEST_VMALLOC_MODULE
References: <20190103142108.20744-1-urezki@gmail.com>
 <20190103142108.20744-4-urezki@gmail.com>
From: shuah <shuah@kernel.org>
Message-ID: <d62089c4-8225-6363-1de5-ff2e8a3f684e@kernel.org>
Date: Fri, 4 Jan 2019 11:34:30 -0700
MIME-Version: 1.0
In-Reply-To: <20190103142108.20744-4-urezki@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Uladzislau Rezki (Sony)" <urezki@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Thomas Gleixner <tglx@linutronix.de>, shuah <shuah@kernel.org>

On 1/3/19 7:21 AM, Uladzislau Rezki (Sony) wrote:
> Add the test script for the kernel test driver to analyse vmalloc
> allocator for benchmarking and stressing purposes. It is just a kernel
> module loader. You can specify and pass different parameters in order
> to investigate allocations behaviour. See "usage" output for more
> details.
> 
> Also add basic vmalloc smoke test to the "run_vmtests" suite.
> 
> Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
> ---

Thanks for adding skip handling. Here is my

Reviewed-by: Shuah Khan <shuah@kernel.org>

for Andrew to take this through mm tree.

thanks,
-- Shuah
