Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id D2C096B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 06:28:44 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id pv20so657lab.29
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 03:28:43 -0700 (PDT)
Received: from mail-la0-x229.google.com (mail-la0-x229.google.com [2a00:1450:4010:c03::229])
        by mx.google.com with ESMTPS id xv4si6991939lab.3.2014.08.27.03.28.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 27 Aug 2014 03:28:43 -0700 (PDT)
Received: by mail-la0-f41.google.com with SMTP id s18so3573lam.14
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 03:28:42 -0700 (PDT)
Date: Wed, 27 Aug 2014 14:28:40 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [next:master 2131/2422] kernel/sys.c:1888 prctl_set_mm_map()
 warn: maybe return -EFAULT instead of the bytes remaining?
Message-ID: <20140827102840.GB8692@moon>
References: <20140827095613.GN5100@mwanda>
 <20140827100909.GA8692@moon>
 <20140827102439.GO5100@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140827102439.GO5100@mwanda>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: kbuild@01.org, Linux Memory Management List <linux-mm@kvack.org>

On Wed, Aug 27, 2014 at 01:24:39PM +0300, Dan Carpenter wrote:
> On Wed, Aug 27, 2014 at 02:09:09PM +0400, Cyrill Gorcunov wrote:
> 
> > Not really sure I'm follow. @error is error code either 0 (on success) or
> > any other if some problem happened.
> 
> 
> It's complaining about this:
> 
> kernel/sys.c
>   1846          if (prctl_map.auxv_size) {
>   1847                  up_read(&mm->mmap_sem);
>   1848                  memset(user_auxv, 0, sizeof(user_auxv));
>   1849                  error = copy_from_user(user_auxv,
>   1850                                         (const void __user *)prctl_map.auxv,
>   1851                                         prctl_map.auxv_size);
>   1852                  down_read(&mm->mmap_sem);
>   1853                  if (error)
>   1854                          goto out;
>   1855          }

Ah, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
