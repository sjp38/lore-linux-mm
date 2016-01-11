Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 13E48828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 08:00:50 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id e65so44769635pfe.0
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 05:00:50 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id f2si19152124pas.32.2016.01.11.05.00.49
        for <linux-mm@kvack.org>;
        Mon, 11 Jan 2016 05:00:49 -0800 (PST)
From: Sakari Ailus <sakari.ailus@linux.intel.com>
Subject: Re: [PATCH 1/1] mm: EXPORT_SYMBOL_GPL(find_vm_area);
References: <1447247184-27939-1-git-send-email-sakari.ailus@linux.intel.com>
 <20151202162558.d0465f11746ff94114c5d987@linux-foundation.org>
Message-ID: <5693A77E.4020809@linux.intel.com>
Date: Mon, 11 Jan 2016 15:00:46 +0200
MIME-Version: 1.0
In-Reply-To: <20151202162558.d0465f11746ff94114c5d987@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

Hi Andrew,

Andrew Morton wrote:
> On Wed, 11 Nov 2015 15:06:24 +0200 Sakari Ailus <sakari.ailus@linux.intel.com> wrote:
> 
>> find_vm_area() is needed in implementing the DMA mapping API as a module.
>> Device specific IOMMUs with associated DMA mapping implementations should be
>> buildable as modules.
>>
>> ...
>>
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -1416,6 +1416,7 @@ struct vm_struct *find_vm_area(const void *addr)
>>  
>>  	return NULL;
>>  }
>> +EXPORT_SYMBOL_GPL(find_vm_area);
> 
> Confused.  Who is setting CONFIG_HAS_DMA=m?
> 

Apologies for the late reply --- CONFIG_HAS_DMA isn't configured as a
module, but some devices are not DMA coherent even on x86. The existing
x86 DMA mapping implementation doesn't quite work for those at the
moment, and nothing prevents using another one (and as a module, in
which case this patch is required).

-- 
Kind regards,

Sakari Ailus
sakari.ailus@linux.intel.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
