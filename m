Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 321066B0003
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 15:23:37 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id u65so18619530pfd.7
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 12:23:37 -0800 (PST)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0121.outbound.protection.outlook.com. [104.47.1.121])
        by mx.google.com with ESMTPS id y7si242418pgr.71.2018.02.01.12.23.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 01 Feb 2018 12:23:36 -0800 (PST)
Subject: Re: [PATCH] mm/kasan: Don't vfree() nonexistent vm_area.
References: <12c9e499-9c11-d248-6a3f-14ec8c4e07f1@molgen.mpg.de>
 <20180201163349.8700-1-aryabinin@virtuozzo.com>
 <20180201195757.GC20742@bombadil.infradead.org>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <e1cf8e8e-4cc4-ff4f-92e1-f6fcf373c67f@virtuozzo.com>
Date: Thu, 1 Feb 2018 23:22:55 +0300
MIME-Version: 1.0
In-Reply-To: <20180201195757.GC20742@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Paul Menzel <pmenzel+linux-kasan-dev@molgen.mpg.de>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org



On 02/01/2018 10:57 PM, Matthew Wilcox wrote:
> On Thu, Feb 01, 2018 at 07:33:49PM +0300, Andrey Ryabinin wrote:
>> +	case MEM_OFFLINE: {
>> +		struct vm_struct *vm;
>> +
>> +		/*
>> +		 * Only hot-added memory have vm_area. Freeing shadow
>> +		 * mapped during boot would be tricky, so we'll just
>> +		 * have to keep it.
>> +		 */
>> +		vm = find_vm_area((void *)shadow_start);
>> +		if (vm)
>> +			vfree((void *)shadow_start);
>> +	}
> 
> This looks like a complicated way to spell 'is_vmalloc_addr' ...
> 

It's not. shadow_start is never vmalloc address.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
