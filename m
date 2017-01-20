Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1356C6B0033
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 06:18:51 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id z128so93018190pfb.4
        for <linux-mm@kvack.org>; Fri, 20 Jan 2017 03:18:51 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a71si6532601pfg.294.2017.01.20.03.18.49
        for <linux-mm@kvack.org>;
        Fri, 20 Jan 2017 03:18:50 -0800 (PST)
Date: Fri, 20 Jan 2017 11:17:47 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH] mm: add arch-independent testcases for RODATA
Message-ID: <20170120111747.GB18576@leverpostej>
References: <20170119145114.GA19772@pjb1027-Latitude-E5410>
 <20170119155701.GA24654@leverpostej>
 <CAErMHp-L-B_9pWVRpqRSpH8LL4VEmHHrFDUbkvNZbXC=uWCzng@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAErMHp-L-B_9pWVRpqRSpH8LL4VEmHHrFDUbkvNZbXC=uWCzng@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: park jinbum <jinb.park7@gmail.com>
Cc: hpa@zytor.com, x86@kernel.org, akpm@linuxfoundation.org, keescook@chromium.org, linux-mm@kvack.org, arjan@linux.intel.com, mingo@redhat.com, tglx@linutronix.de, linux@armlinux.org.uk, kernel-janitors@vger.kernel.org, kernel-hardening@lists.openwall.com, labbott@redhat.com, linux-kernel@vger.kernel.org

On Fri, Jan 20, 2017 at 03:49:46PM +0900, park jinbum wrote:
> Where is the best place for common test file in general??
> 
>  kernel/rodata_test.c
>  include/rodata_test.h => Is it fine??

I had assumed you would use mm/rodata_test.c, as you do in this patch
(i.e. a *new* common file). That seems fine to me.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
