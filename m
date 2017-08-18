Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id C29796B03A1
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 12:57:50 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id 130so7339316qkg.5
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 09:57:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h203si5458251qke.289.2017.08.18.09.57.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Aug 2017 09:57:50 -0700 (PDT)
Subject: Re: [memcg:since-4.12 539/540] mm/compaction.c:469:8: error: implicit
 declaration of function 'pageblock_skip_persistent'
References: <201708190034.TmrRSDV7%fengguang.wu@intel.com>
From: Waiman Long <longman@redhat.com>
Message-ID: <fac0ae1a-7de3-bb98-53c8-f63f205f5c04@redhat.com>
Date: Fri, 18 Aug 2017 12:57:48 -0400
MIME-Version: 1.0
In-Reply-To: <201708190034.TmrRSDV7%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>

On 08/18/2017 12:42 PM, kbuild test robot wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-4.12
> head:   ba5e8c23db5729ebdbafad983b07434c829cf5b6
> commit: 500539d3686a835f6a9740ffc38bed5d74951a64 [539/540] debugobjects: make kmemleak ignore debug objects
> config: i386-randconfig-s0-08141822 (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         git checkout 500539d3686a835f6a9740ffc38bed5d74951a64
>         # save the attached .config to linux build tree
>         make ARCH=i386 
>
> All errors (new ones prefixed by >>):
>
>    mm/compaction.c: In function 'isolate_freepages_block':
>>> mm/compaction.c:469:8: error: implicit declaration of function 'pageblock_skip_persistent' [-Werror=implicit-function-declaration]
>        if (pageblock_skip_persistent(page, order)) {
>            ^~~~~~~~~~~~~~~~~~~~~~~~~
>>> mm/compaction.c:470:5: error: implicit declaration of function 'set_pageblock_skip' [-Werror=implicit-function-declaration]
>         set_pageblock_skip(page);
>         ^~~~~~~~~~~~~~~~~~
>    cc1: some warnings being treated as errors
>
> vim +/pageblock_skip_persistent +469 mm/compaction.c

It is not me. My patch doesn't touch any header file and
mm/compaction.c. So it can't cause this kind of errors.

Cheers,
Longman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
