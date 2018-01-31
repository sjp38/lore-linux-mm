Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5AFFB6B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 21:33:13 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id r75so3194716qke.6
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 18:33:13 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id k2si103808qtc.210.2018.01.30.18.33.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jan 2018 18:33:12 -0800 (PST)
Subject: Re: [PATCH 3/3] mm: memfd: remove memfd code from shmem files and use
 new memfd files
References: <20180130000101.7329-4-mike.kravetz@oracle.com>
 <201801310705.HNIeJce6%fengguang.wu@intel.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <6225b786-ebd6-6d3b-3db8-55b87dc9a8bd@oracle.com>
Date: Tue, 30 Jan 2018 18:28:03 -0800
MIME-Version: 1.0
In-Reply-To: <201801310705.HNIeJce6%fengguang.wu@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@gmail.com>, David Herrmann <dh.herrmann@gmail.com>, Khalid Aziz <khalid.aziz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>

On 01/30/2018 03:49 PM, kbuild test robot wrote:
> Hi Mike,
> 
> Thank you for the patch! Perhaps something to improve:
> 
> [auto build test WARNING on mmotm/master]
> [also build test WARNING on next-20180126]
> [cannot apply to linus/master v4.15]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Mike-Kravetz/restructure-memfd-code/20180131-023405
> base:   git://git.cmpxchg.org/linux-mmotm.git master
> reproduce:
>         # apt-get install sparse
>         make ARCH=x86_64 allmodconfig
>         make C=1 CF=-D__CHECK_ENDIAN__
> 
> 
> sparse warnings: (new ones prefixed by >>)
> 
>>> mm/memfd.c:40:9: sparse: incorrect type in assignment (different address spaces) @@ expected void @@ got void <avoid @@

<snip>

> :::::: The code at line 40 was first introduced by commit
> :::::: 6df4ed2a410bc04f1ec04dce16ccd236707f7f32 mm: memfd: split out memfd for use by multiple filesystems

Yes, but I also removed those same warnings from mm/shmem.c so I should
get some credit for that. :)

I fixed up the warnings in the moved code and will send out v2.
-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
