Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id CA0136B0009
	for <linux-mm@kvack.org>; Sat, 10 Feb 2018 18:00:14 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id 17so1016439wma.1
        for <linux-mm@kvack.org>; Sat, 10 Feb 2018 15:00:14 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id m81si1525225wmi.55.2018.02.10.15.00.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Feb 2018 15:00:13 -0800 (PST)
Subject: Re: [PATCH 2/6] genalloc: selftest
References: <20180204164732.28241-1-igor.stoppa@huawei.com>
 <20180204164732.28241-3-igor.stoppa@huawei.com>
 <e05598c1-3c7c-15c6-7278-ed52ceff0acf@infradead.org>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <0183b04c-1fde-4840-2977-c9eea77e0c99@huawei.com>
Date: Sun, 11 Feb 2018 00:59:58 +0200
MIME-Version: 1.0
In-Reply-To: <e05598c1-3c7c-15c6-7278-ed52ceff0acf@infradead.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>, jglisse@redhat.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, hch@infradead.org, willy@infradead.org
Cc: cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On 05/02/18 00:19, Randy Dunlap wrote:
> On 02/04/2018 08:47 AM, Igor Stoppa wrote:

[...]

> Please use kernel multi-line comment style.

ok for all of them

[...]

>> +	BUG_ON(!locations[action->location]);
>> +	print_first_chunk_bitmap(pool);
>> +	BUG_ON(compare_bitmaps(pool, action->pattern));
> 
> BUG_ON() seems harsh to me, but some of the other self-tests also do that.

I would expect that the test never fails, if one is not modifying
anything related to genalloc.

But if an error slips in during development of genalloc or anything
related (like the functions used to scan the bitmaps), I think it's
better to pull the handbrake immediately, because failure in tracking
correctly the memory allocation is likely to cause corruption and every
sort of mysterious weird errors.

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
