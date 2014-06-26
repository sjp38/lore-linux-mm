Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id 17E3E6B0035
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 22:02:00 -0400 (EDT)
Received: by mail-yk0-f177.google.com with SMTP id 10so1631058ykt.22
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 19:01:59 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id t31si8363715yhe.60.2014.06.25.19.01.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 25 Jun 2014 19:01:59 -0700 (PDT)
Message-ID: <53AB7F0B.5050900@oracle.com>
Date: Thu, 26 Jun 2014 10:01:47 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [next:master 156/212] fs/binfmt_elf.c:158:18: note: in expansion
 of macro 'min'
References: <53aa90d2.Yd3WgTmElIsuiwuV%fengguang.wu@intel.com> <20140625100213.GA1866@localhost> <53AAB2D3.2050809@oracle.com> <alpine.DEB.2.02.1406251543080.4592@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1406251543080.4592@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


On 06/26/2014 06:44 AM, David Rientjes wrote:
> On Wed, 25 Jun 2014, Jeff Liu wrote:
> 
>>>    fs/binfmt_elf.c: In function 'get_atrandom_bytes':
>>>    include/linux/kernel.h:713:17: warning: comparison of distinct pointer types lacks a cast
>>>      (void) (&_min1 == &_min2);  \
>>>                     ^
>>>>> fs/binfmt_elf.c:158:18: note: in expansion of macro 'min'
>>>       size_t chunk = min(nbytes, sizeof(random_variable));
>>
>> I remember we have the same report on arch mn10300 about half a year ago, but the code
>> is correct. :)
>>
> 
> Casting the sizeof operator to size_t would fix this issue on am33.

Thanks for pointing this out, I once considered to use min_t() to do explicitly casting.
However, both values to compare are already size_t, maybe this depending on the compiler's
result of what sizeof() would be...


Cheers,
-Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
