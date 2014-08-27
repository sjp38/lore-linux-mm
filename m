Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7FEBC6B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 06:09:14 -0400 (EDT)
Received: by mail-la0-f44.google.com with SMTP id el20so16487831lab.17
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 03:09:13 -0700 (PDT)
Received: from mail-lb0-x235.google.com (mail-lb0-x235.google.com [2a00:1450:4010:c04::235])
        by mx.google.com with ESMTPS id w7si6793231lbv.79.2014.08.27.03.09.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 27 Aug 2014 03:09:12 -0700 (PDT)
Received: by mail-lb0-f181.google.com with SMTP id 10so2854082lbg.12
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 03:09:12 -0700 (PDT)
Date: Wed, 27 Aug 2014 14:09:09 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [next:master 2131/2422] kernel/sys.c:1888 prctl_set_mm_map()
 warn: maybe return -EFAULT instead of the bytes remaining?
Message-ID: <20140827100909.GA8692@moon>
References: <20140827095613.GN5100@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140827095613.GN5100@mwanda>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: kbuild@01.org, Linux Memory Management List <linux-mm@kvack.org>

On Wed, Aug 27, 2014 at 12:56:13PM +0300, Dan Carpenter wrote:
> 
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   d05446ae2128064a4bb8f74c84f6901ffb5c94bc
> commit: 802d335c0f7f1a1867bf59814c55970a71b10413 [2131/2422] prctl: PR_SET_MM -- introduce PR_SET_MM_MAP operation
> 
> kernel/sys.c:1888 prctl_set_mm_map() warn: maybe return -EFAULT instead of the bytes remaining?
> 
> git remote add next git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
> git remote update next
> git checkout 802d335c0f7f1a1867bf59814c55970a71b10413
> vim +1888 kernel/sys.c
> 
> 802d335c Cyrill Gorcunov 2014-08-26  1872  
> 802d335c Cyrill Gorcunov 2014-08-26  1873  	mm->start_code	= prctl_map.start_code;
> 802d335c Cyrill Gorcunov 2014-08-26  1874  	mm->end_code	= prctl_map.end_code;
> 802d335c Cyrill Gorcunov 2014-08-26  1875  	mm->start_data	= prctl_map.start_data;
> 802d335c Cyrill Gorcunov 2014-08-26  1876  	mm->end_data	= prctl_map.end_data;
> 802d335c Cyrill Gorcunov 2014-08-26  1877  	mm->start_brk	= prctl_map.start_brk;
> 802d335c Cyrill Gorcunov 2014-08-26  1878  	mm->brk		= prctl_map.brk;
> 802d335c Cyrill Gorcunov 2014-08-26  1879  	mm->start_stack	= prctl_map.start_stack;
> 802d335c Cyrill Gorcunov 2014-08-26  1880  	mm->arg_start	= prctl_map.arg_start;
> 802d335c Cyrill Gorcunov 2014-08-26  1881  	mm->arg_end	= prctl_map.arg_end;
> 802d335c Cyrill Gorcunov 2014-08-26  1882  	mm->env_start	= prctl_map.env_start;
> 802d335c Cyrill Gorcunov 2014-08-26  1883  	mm->env_end	= prctl_map.env_end;
> 802d335c Cyrill Gorcunov 2014-08-26  1884  
> 802d335c Cyrill Gorcunov 2014-08-26  1885  	error = 0;
> 802d335c Cyrill Gorcunov 2014-08-26  1886  out:
> 802d335c Cyrill Gorcunov 2014-08-26  1887  	up_read(&mm->mmap_sem);
> 802d335c Cyrill Gorcunov 2014-08-26 @1888  	return error;

Not really sure I'm follow. @error is error code either 0 (on success) or
any other if some problem happened.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
