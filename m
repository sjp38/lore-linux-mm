Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 17B316B0037
	for <linux-mm@kvack.org>; Fri, 28 Mar 2014 06:33:39 -0400 (EDT)
Received: by mail-ig0-f169.google.com with SMTP id h18so643975igc.4
        for <linux-mm@kvack.org>; Fri, 28 Mar 2014 03:33:38 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTP id hl3si6217306icc.35.2014.03.28.03.33.32
        for <linux-mm@kvack.org>;
        Fri, 28 Mar 2014 03:33:38 -0700 (PDT)
Message-ID: <53354D68.6040800@huawei.com>
Date: Fri, 28 Mar 2014 18:22:32 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 2/4] kmemleak: allow freeing internal objects after
 kmemleak was disabled
References: <5335384A.2000000@huawei.com> <5335387E.2050005@huawei.com> <20140328101315.GB21330@arm.com>
In-Reply-To: <20140328101315.GB21330@arm.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

>> +	if (!kmemleak_has_leaks)
>> +		__kmemleak_do_cleanup();
>> +	else
>> +		pr_info("Disable kmemleak without freeing internal objects, "
>> +			"so you may still check information on memory leaks. "
>> +			"You may reclaim memory by writing \"clear\" to "
>> +			"/sys/kernel/debug/kmemleak\n");
> 
> Alternative text:
> 
> 		pr_info("Kmemleak disabled without freeing internal data. "
> 			"Reclaim the memory with \"echo clear > /sys/kernel/debug/kmemleak\"\n");
> 
> (I'm wouldn't bother with long lines in printk strings)
> 
> Otherwise:
> 
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> 

Thanks for the review!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
