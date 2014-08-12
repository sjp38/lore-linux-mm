Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 729876B0035
	for <linux-mm@kvack.org>; Tue, 12 Aug 2014 03:13:59 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id v10so10452332pde.11
        for <linux-mm@kvack.org>; Tue, 12 Aug 2014 00:13:59 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id ve8si15362620pbc.6.2014.08.12.00.13.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 12 Aug 2014 00:13:58 -0700 (PDT)
Received: by mail-pa0-f42.google.com with SMTP id lf10so12593346pab.1
        for <linux-mm@kvack.org>; Tue, 12 Aug 2014 00:13:57 -0700 (PDT)
Date: Tue, 12 Aug 2014 07:18:30 +0000
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 2/3] zsmalloc/zram: add zs_get_max_size_bytes and use it in
 zram
Message-ID: <20140812071830.GA23902@gmail.com>
References: <loom.20140808T045014-594@post.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <loom.20140808T045014-594@post.gmane.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Horner <ds2horner@gmail.com>
Cc: linux-mm@kvack.org

Hello,

Sorry for the late response. I was on vacation and then was busy.

On Fri, Aug 08, 2014 at 02:56:24AM +0000, David Horner wrote:
> 
>  [2/3]
> 
> 
>  But why isn't mem_used_max writable? (save tearing down and rebuilding
>  device to reset max)

I don't know what you mean but I will make it writable so user can
reset it to zero when they want.

> 
>  static DEVICE_ATTR(mem_used_max, S_IRUGO, mem_used_max_show, NULL);
> 
>  static DEVICE_ATTR(mem_used_max, S_IRUGO | S_IWUSR, mem_used_max_show, NULL);
> 
>    with a check in the store() that the new value is positive and less
> than current max?
> 
> 
>  I'm also a little puzzled why there is a new API zs_get_max_size_bytes if
>  the data is accessible through sysfs?
>  Especially if max limit will be (as you propose for [3/3]) through accessed
>  through zsmalloc and hence zram needn't access.

I don't know why you meant.
Anyway, I will resend revised version and Cc you.
Please, comment on that. :)

> 
> 
> 
>   [3/3]
>  I concur that the zram limit is best implemented in zsmalloc.
>  I am looking forward to that revised code.

Thanks!

> 
> 
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
