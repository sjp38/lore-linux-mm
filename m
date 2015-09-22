Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 0BD656B0256
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 16:30:03 -0400 (EDT)
Received: by pacbt3 with SMTP id bt3so437873pac.3
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 13:30:02 -0700 (PDT)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id kh9si4984385pab.221.2015.09.22.13.29.57
        for <linux-mm@kvack.org>;
        Tue, 22 Sep 2015 13:29:57 -0700 (PDT)
Subject: Re: [PATCH 10/26] x86, pkeys: notify userspace about protection key
 faults
References: <20150916174903.E112E464@viggo.jf.intel.com>
 <20150916174906.51062FBC@viggo.jf.intel.com>
 <alpine.DEB.2.11.1509222157050.5606@nanos> <5601B82F.6070601@sr71.net>
 <alpine.DEB.2.11.1509222226090.5606@nanos>
From: Dave Hansen <dave@sr71.net>
Message-ID: <5601BA44.8080604@sr71.net>
Date: Tue, 22 Sep 2015 13:29:56 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1509222226090.5606@nanos>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 09/22/2015 01:27 PM, Thomas Gleixner wrote:
>> > 
>> > So I defined all the kernel-internal types as u16 since I *know* the
>> > size of the hardware.
>> > 
>> > The user-exposed ones should probably be a bit more generic.  I did just
>> > realize that this is an int and my proposed syscall is a long.  That I
>> > definitely need to make consistent.
>> > 
>> > Does anybody care whether it's an int or a long?
> long is frowned upon due to 32/64bit. Even if that key stuff is only
> available on 64bit for now ....

Well, it can be used by 32-bit apps on 64-bit kernels.

Ahh, that's why we don't see any longs in the siginfo.  So does that
mean 'int' is still our best bet in siginfo?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
