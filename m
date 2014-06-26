Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 7F3546B0031
	for <linux-mm@kvack.org>; Thu, 26 Jun 2014 03:47:44 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id fp1so2713251pdb.2
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 00:47:44 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id kd3si8678615pbc.49.2014.06.26.00.47.42
        for <linux-mm@kvack.org>;
        Thu, 26 Jun 2014 00:47:43 -0700 (PDT)
Date: Thu, 26 Jun 2014 15:47:35 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [next:master 156/212] fs/binfmt_elf.c:158:18: note: in expansion
 of macro 'min'
Message-ID: <20140626074735.GA24582@localhost>
References: <53aa90d2.Yd3WgTmElIsuiwuV%fengguang.wu@intel.com>
 <20140625100213.GA1866@localhost>
 <53AAB2D3.2050809@oracle.com>
 <alpine.DEB.2.02.1406251543080.4592@chino.kir.corp.google.com>
 <53AB7F0B.5050900@oracle.com>
 <alpine.DEB.2.02.1406252310560.3960@chino.kir.corp.google.com>
 <53ABBEA0.1010307@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53ABBEA0.1010307@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Liu <jeff.liu@oracle.com>
Cc: David Rientjes <rientjes@google.com>, kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, Jun 26, 2014 at 02:33:04PM +0800, Jeff Liu wrote:
> 
> On 06/26/2014 14:19 PM, David Rientjes wrote:
> > On Thu, 26 Jun 2014, Jeff Liu wrote:
> > 
> >>>>>    fs/binfmt_elf.c: In function 'get_atrandom_bytes':
> >>>>>    include/linux/kernel.h:713:17: warning: comparison of distinct pointer types lacks a cast
> >>>>>      (void) (&_min1 == &_min2);  \
> >>>>>                     ^
> >>>>>>> fs/binfmt_elf.c:158:18: note: in expansion of macro 'min'
> >>>>>       size_t chunk = min(nbytes, sizeof(random_variable));
> >>>>
> >>>> I remember we have the same report on arch mn10300 about half a year ago, but the code
> >>>> is correct. :)
> >>>>
> >>>
> >>> Casting the sizeof operator to size_t would fix this issue on am33.
> >>
> >> Thanks for pointing this out, I once considered to use min_t() to do explicitly casting.
> >> However, both values to compare are already size_t, maybe this depending on the compiler's
> >> result of what sizeof() would be...
> >>
> > 
> > Have you read arch/mn10300/include/uapi/asm/posix_types.h?  am33 defines 
> > this to be unsigned int for gcc version 4.  You would not see this warning 
> > with gcc major version != 4 or if you do what I suggested and cast it to 
> > size_t.
> 
> Ah, that solves it, thanks! 0day tests with am33 cross compiler version 4.6.3.

And it'll soon be upgraded to 4.9.0. :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
