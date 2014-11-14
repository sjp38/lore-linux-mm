Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 249346B00E3
	for <linux-mm@kvack.org>; Fri, 14 Nov 2014 03:20:58 -0500 (EST)
Received: by mail-wg0-f44.google.com with SMTP id x12so18917353wgg.31
        for <linux-mm@kvack.org>; Fri, 14 Nov 2014 00:20:57 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d5si48150571wjs.63.2014.11.14.00.20.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 14 Nov 2014 00:20:56 -0800 (PST)
Message-ID: <1415953238.4534.2.camel@linux-t7sj.site>
Subject: Re: [PATCH] mm: fix overly aggressive shmdt() when calls span
 multiple segments
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Fri, 14 Nov 2014 00:20:38 -0800
In-Reply-To: <20141104000633.F35632C6@viggo.jf.intel.com>
References: <20141104000633.F35632C6@viggo.jf.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, dave.hansen@linux.intel.com

On Mon, 2014-11-03 at 16:06 -0800, Dave Hansen wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> This is a highly-contrived scenario.  But, a single shmdt() call
> can be induced in to unmapping memory from mulitple shm segments.
> Example code is here:
> 
> 	http://www.sr71.net/~dave/intel/shmfun.c
> 
> The fix is pretty simple:  Record the 'struct file' for the first
> VMA we encounter and then stick to it.  Decline to unmap anything
> not from the same file and thus the same segment.
> 
> I found this by inspection and the odds of anyone hitting this in
> practice are pretty darn small.
> 
> Lightly tested, but it's a pretty small patch.

Passed shmdt ltp tests, fwiw.

> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Reviewed-by: Davidlohr Bueso <dave@stgolabs.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
