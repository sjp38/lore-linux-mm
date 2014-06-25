Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 034916B0037
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 18:44:45 -0400 (EDT)
Received: by mail-ig0-f179.google.com with SMTP id uq10so27146igb.12
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 15:44:45 -0700 (PDT)
Received: from mail-ig0-x22a.google.com (mail-ig0-x22a.google.com [2607:f8b0:4001:c05::22a])
        by mx.google.com with ESMTPS id ce6si8127223icc.61.2014.06.25.15.44.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Jun 2014 15:44:44 -0700 (PDT)
Received: by mail-ig0-f170.google.com with SMTP id h15so103860igd.3
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 15:44:44 -0700 (PDT)
Date: Wed, 25 Jun 2014 15:44:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [next:master 156/212] fs/binfmt_elf.c:158:18: note: in expansion
 of macro 'min'
In-Reply-To: <53AAB2D3.2050809@oracle.com>
Message-ID: <alpine.DEB.2.02.1406251543080.4592@chino.kir.corp.google.com>
References: <53aa90d2.Yd3WgTmElIsuiwuV%fengguang.wu@intel.com> <20140625100213.GA1866@localhost> <53AAB2D3.2050809@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Liu <jeff.liu@oracle.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, 25 Jun 2014, Jeff Liu wrote:

> >    fs/binfmt_elf.c: In function 'get_atrandom_bytes':
> >    include/linux/kernel.h:713:17: warning: comparison of distinct pointer types lacks a cast
> >      (void) (&_min1 == &_min2);  \
> >                     ^
> >>> fs/binfmt_elf.c:158:18: note: in expansion of macro 'min'
> >       size_t chunk = min(nbytes, sizeof(random_variable));
> 
> I remember we have the same report on arch mn10300 about half a year ago, but the code
> is correct. :)
> 

Casting the sizeof operator to size_t would fix this issue on am33.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
