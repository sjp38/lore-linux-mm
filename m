Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EA5AE6B00B6
	for <linux-mm@kvack.org>; Wed, 10 Mar 2010 10:23:24 -0500 (EST)
Subject: Re: [BUG] 2.6.33-mmotm-100302
 "page-allocator-reduce-fragmentation-in-buddy-allocator..."  patch causes
 Oops at boot
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <4e5e476b1003091403h361984acocc71377660317373@mail.gmail.com>
References: <1267644632.4023.28.camel@useless.americas.hpqcorp.net>
	 <4e5e476b1003091403h361984acocc71377660317373@mail.gmail.com>
Content-Type: text/plain
Date: Wed, 10 Mar 2010 10:23:18 -0500
Message-Id: <1268234598.4184.7.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Corrado Zoccolo <czoccolo@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-03-09 at 23:03 +0100, Corrado Zoccolo wrote:
> Hi Lee,
> the correct fix is attached.
> It has the good property that the check is compiled out when not
> needed (i.e. when !CONFIG_HOLES_IN_ZONE).
> Can you give it a spin on your machine?
> 
> Thanks,
> Corrado
> 


Corrado:

That, indeed, fixed the problem.  I applied your patch to 2.6.33 + the
4mar mmotm and it booted fine on the same hardware config that was
failing before.  You can add my

Tested-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

Thanks, 
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
