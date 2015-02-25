Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id ED2B06B0032
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 15:18:52 -0500 (EST)
Received: by wghk14 with SMTP id k14so6027296wgh.4
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 12:18:52 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id jj6si31175872wid.41.2015.02.25.12.18.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Feb 2015 12:18:50 -0800 (PST)
Date: Wed, 25 Feb 2015 15:18:37 -0500 (EST)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: Question about Old  Fix Me comment in mempool.c
In-Reply-To: <5491075B.9080609@gmail.com>
Message-ID: <alpine.LRH.2.02.1502251513080.16745@file01.intranet.prod.int.rdu2.redhat.com>
References: <5491075B.9080609@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nick <xerofoify@gmail.com>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, sebott@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On Tue, 16 Dec 2014, nick wrote:

> Greetings Andrew and other maintainers,
> I am wondering why the below comment is even in mempool.c and this has not been changed to a call to io_schedule as the kernel version is stupidly old and this should be fixed by now and the issues with DM would have been removed by now. 
> /*
>          * FIXME: this should be io_schedule().  The timeout is there as a
>          * workaround for some DM problems in 2.6.18.
>         */
> 
> Sorry for the stupid question but I like to double check with the maintainers before I sent in a patch for things like this to see if I am missing anything:).
> 
> Thanks for Your Time,
> Nick 

There are still some bugs with respect to this (and they will probably 
never be removed all) - for example this bug which wasn't fixed yet 
http://www.redhat.com/archives/dm-devel/2014-May/msg00089.html .

So, you should not remove it.

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
