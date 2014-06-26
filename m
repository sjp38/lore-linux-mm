Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5DFE66B0037
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 21:46:08 -0400 (EDT)
Received: by mail-yh0-f47.google.com with SMTP id v1so1724914yhn.34
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 18:46:08 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id d61si8332514yho.40.2014.06.25.18.46.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 25 Jun 2014 18:46:07 -0700 (PDT)
Message-ID: <53AB7B54.3030003@oracle.com>
Date: Thu, 26 Jun 2014 09:45:56 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [next:master 156/212] fs/binfmt_elf.c:158:18: note: in expansion
 of macro 'min'
References: <53aa90d2.Yd3WgTmElIsuiwuV%fengguang.wu@intel.com>	<20140625100213.GA1866@localhost>	<53AAB2D3.2050809@oracle.com> <20140625125926.127128b7bb82cb5dc9c7e01c@linux-foundation.org>
In-Reply-To: <20140625125926.127128b7bb82cb5dc9c7e01c@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>


On 06/26/2014 03:59 PM, Andrew Morton wrote:
> On Wed, 25 Jun 2014 19:30:27 +0800 Jeff Liu <jeff.liu@oracle.com> wrote:
> 
>>
>> On 06/25/2014 18:02 PM, Fengguang Wu wrote:

<snip>

>>>    fs/binfmt_elf.c: In function 'get_atrandom_bytes':
>>>    include/linux/kernel.h:713:17: warning: comparison of distinct pointer types lacks a cast
>>>      (void) (&_min1 == &_min2);  \
>>>                     ^
>>>>> fs/binfmt_elf.c:158:18: note: in expansion of macro 'min'
>>>       size_t chunk = min(nbytes, sizeof(random_variable));
>>
>> I remember we have the same report on arch mn10300 about half a year ago, but the code
>> is correct. :)
> 
> We really need to do something about this patch - it's been stuck in
> -mm for ever.
> 
> I have a note here that Stephan Mueller identified issues with it but I
> don't recall what they were - do you? 

Yes, Stephan noted a couple of issues here:
https://lkml.org/lkml/2012/12/14/267

> 
> Maybe you could go back through the list dicussion, identify all/any
> issues which were raised, update the changelog to address them then
> resend it, copying people who were involved in the earlier discussion?

Ok, I'll take care of it.


Cheers,
-Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
