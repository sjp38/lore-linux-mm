Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id C28496B06D1
	for <linux-mm@kvack.org>; Sat, 19 May 2018 10:31:44 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id a5-v6so6908313plp.8
        for <linux-mm@kvack.org>; Sat, 19 May 2018 07:31:44 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id e84-v6si9899085pfk.198.2018.05.19.07.31.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 May 2018 07:31:43 -0700 (PDT)
Date: Sat, 19 May 2018 22:31:39 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [mmotm:master 149/199] lib/idr.c:583:2: error: implicit
 declaration of function 'xa_lock_irqsave'; did you mean 'read_lock_irqsave'?
Message-ID: <20180519143139.2bryoecv4qwbhgtr@wfg-t540p.sh.intel.com>
References: <201805190415.2D1H4m65%fengguang.wu@intel.com>
 <20180518151000.93517f28f3338bb39f558a90@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20180518151000.93517f28f3338bb39f558a90@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <lkp@intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>, "Hao, Shun" <shun.hao@intel.com>

Hi Andrew,

On Fri, May 18, 2018 at 03:10:00PM -0700, Andrew Morton wrote:
>On Sat, 19 May 2018 04:21:17 +0800 kbuild test robot <lkp@intel.com> wrote:
>
>> tree:   git://git.cmpxchg.org/linux-mmotm.git master
>> head:   7400fc6942aefa2e009272d0e118284f110c5088
>> commit: d5f90621ff2af7f139b01b7bcf8649a91665965e [149/199] lib/idr.c: remove simple_ida_lock
>> config: x86_64-randconfig-i0-201819 (attached as .config)
>> compiler: gcc-7 (Debian 7.3.0-16) 7.3.0
>> reproduce:
>>         git checkout d5f90621ff2af7f139b01b7bcf8649a91665965e
>>         # save the attached .config to linux build tree
>>         make ARCH=x86_64
>>
>> Note: the mmotm/master HEAD 7400fc6942aefa2e009272d0e118284f110c5088 builds fine.
>>       It only hurts bisectibility.
>>
>
>I'm a bit surprised we're seeing this.
>ida-remove-simple_ida_lock.patch introduces this error, and the very
>next patch ida-remove-simple_ida_lock-fix.patch fixes it.
>
>I'm pretty sure that the robot software is capable of detecting this
>situation and ignoring the error.  Did that code get broken?

Yes sorry, the robot code looks not reliable when testing the follow
up -fix patches. The check is done when first seeing the error instead
of before sending out the final report. In the 2 cases, the next patch
of the error commit could be subtly different.

Shun Hao: to be 100% reliable, we'll also need to check the follow up
-fix patches just before sending out the report.

Thanks,
Fengguang
