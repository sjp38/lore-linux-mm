Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4FB1A6B0255
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 04:06:02 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so226914500wic.0
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 01:06:01 -0700 (PDT)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com. [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id d7si7861319wjb.4.2015.09.23.01.06.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Sep 2015 01:06:01 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so57033630wic.1
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 01:06:01 -0700 (PDT)
Date: Wed, 23 Sep 2015 10:05:58 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 10/26] x86, pkeys: notify userspace about protection key
 faults
Message-ID: <20150923080558.GA28876@gmail.com>
References: <20150916174903.E112E464@viggo.jf.intel.com>
 <20150916174906.51062FBC@viggo.jf.intel.com>
 <alpine.DEB.2.11.1509222157050.5606@nanos>
 <5601B82F.6070601@sr71.net>
 <alpine.DEB.2.11.1509222226090.5606@nanos>
 <5601BA44.8080604@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5601BA44.8080604@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>


* Dave Hansen <dave@sr71.net> wrote:

> On 09/22/2015 01:27 PM, Thomas Gleixner wrote:
> >> > 
> >> > So I defined all the kernel-internal types as u16 since I *know* the
> >> > size of the hardware.
> >> > 
> >> > The user-exposed ones should probably be a bit more generic.  I did just
> >> > realize that this is an int and my proposed syscall is a long.  That I
> >> > definitely need to make consistent.
> >> > 
> >> > Does anybody care whether it's an int or a long?
> > long is frowned upon due to 32/64bit. Even if that key stuff is only
> > available on 64bit for now ....
> 
> Well, it can be used by 32-bit apps on 64-bit kernels.
> 
> Ahh, that's why we don't see any longs in the siginfo.  So does that
> mean 'int' is still our best bet in siginfo?

Use {s|u}{8|16|32|64} integer types in ABI relevant interfaces please, they are 
our most unambiguous and constant types.

Here that would mean s32 or u32?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
