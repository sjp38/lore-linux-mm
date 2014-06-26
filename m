Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id BBA0C6B0031
	for <linux-mm@kvack.org>; Thu, 26 Jun 2014 02:19:24 -0400 (EDT)
Received: by mail-ie0-f182.google.com with SMTP id rp18so2650874iec.27
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 23:19:24 -0700 (PDT)
Received: from mail-ie0-x236.google.com (mail-ie0-x236.google.com [2607:f8b0:4001:c03::236])
        by mx.google.com with ESMTPS id c7si706895igl.17.2014.06.25.23.19.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Jun 2014 23:19:24 -0700 (PDT)
Received: by mail-ie0-f182.google.com with SMTP id rp18so2650870iec.27
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 23:19:24 -0700 (PDT)
Date: Wed, 25 Jun 2014 23:19:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [next:master 156/212] fs/binfmt_elf.c:158:18: note: in expansion
 of macro 'min'
In-Reply-To: <53AB7F0B.5050900@oracle.com>
Message-ID: <alpine.DEB.2.02.1406252310560.3960@chino.kir.corp.google.com>
References: <53aa90d2.Yd3WgTmElIsuiwuV%fengguang.wu@intel.com> <20140625100213.GA1866@localhost> <53AAB2D3.2050809@oracle.com> <alpine.DEB.2.02.1406251543080.4592@chino.kir.corp.google.com> <53AB7F0B.5050900@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Liu <jeff.liu@oracle.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, 26 Jun 2014, Jeff Liu wrote:

> >>>    fs/binfmt_elf.c: In function 'get_atrandom_bytes':
> >>>    include/linux/kernel.h:713:17: warning: comparison of distinct pointer types lacks a cast
> >>>      (void) (&_min1 == &_min2);  \
> >>>                     ^
> >>>>> fs/binfmt_elf.c:158:18: note: in expansion of macro 'min'
> >>>       size_t chunk = min(nbytes, sizeof(random_variable));
> >>
> >> I remember we have the same report on arch mn10300 about half a year ago, but the code
> >> is correct. :)
> >>
> > 
> > Casting the sizeof operator to size_t would fix this issue on am33.
> 
> Thanks for pointing this out, I once considered to use min_t() to do explicitly casting.
> However, both values to compare are already size_t, maybe this depending on the compiler's
> result of what sizeof() would be...
> 

Have you read arch/mn10300/include/uapi/asm/posix_types.h?  am33 defines 
this to be unsigned int for gcc version 4.  You would not see this warning 
with gcc major version != 4 or if you do what I suggested and cast it to 
size_t.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
