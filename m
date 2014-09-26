Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id E0EFB6B0038
	for <linux-mm@kvack.org>; Fri, 26 Sep 2014 03:31:29 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so2849607pab.32
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 00:31:29 -0700 (PDT)
Received: from mail-pd0-x22b.google.com (mail-pd0-x22b.google.com [2607:f8b0:400e:c02::22b])
        by mx.google.com with ESMTPS id zs1si7569848pbc.225.2014.09.26.00.31.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 26 Sep 2014 00:31:28 -0700 (PDT)
Received: by mail-pd0-f171.google.com with SMTP id y13so12367705pdi.2
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 00:31:28 -0700 (PDT)
Date: Fri, 26 Sep 2014 00:31:23 -0700
From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: mmotm 2014-09-25-16-28 uploaded
Message-ID: <20140926073123.GA3033@roeck-us.net>
References: <5424a53b.o+nym6SX0Tg7EdW6%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5424a53b.o+nym6SX0Tg7EdW6%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz

On Thu, Sep 25, 2014 at 04:28:59PM -0700, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2014-09-25-16-28 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 
> mmotm-readme.txt says
> 
> README for mm-of-the-moment:
> 
> http://www.ozlabs.org/~akpm/mmotm/
> 
> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> more than once a week.
> 

Build results:
	total: 133 pass: 10 fail: 123

I won't list all the broken builds.

problem is due to

include/linux/signal.h: In function 'sigisemptyset':
include/linux/signal.h:79:3: error: implicit declaration of function 'BUILD_BUG'

as far as I can see.

Detailed build results are available at http://server.roeck-us.net:8010/builders.

Guenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
