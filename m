Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9129C6B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 17:10:35 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id fg1so66038715pad.1
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 14:10:35 -0700 (PDT)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id k8si2633353pfb.102.2016.06.02.14.10.34
        for <linux-mm@kvack.org>;
        Thu, 02 Jun 2016 14:10:34 -0700 (PDT)
Subject: Re: [PATCH 5/8] x86, pkeys: allocation/free syscalls
References: <20160531152814.36E0B9EE@viggo.jf.intel.com>
 <20160531152822.FE8D405E@viggo.jf.intel.com> <5864297.Wx4gj9qW7E@wuerfel>
From: Dave Hansen <dave@sr71.net>
Message-ID: <5750A0C9.7060409@sr71.net>
Date: Thu, 2 Jun 2016 14:10:33 -0700
MIME-Version: 1.0
In-Reply-To: <5864297.Wx4gj9qW7E@wuerfel>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, dave.hansen@linux.intel.com

On 06/01/2016 01:48 PM, Arnd Bergmann wrote:
>> +330    common  pkey_alloc              sys_pkey_alloc
>> > +331    common  pkey_free               sys_pkey_free
>> >  
>> >  #
>> >  # x32-specific system call numbers start at 512 to avoid cache impact
>> > 
> Could you also add the system call numbers to
> include/uapi/asm-generic/unistd.h at the same time?

Yep, I can do that.  I'll add it to my next series that I post.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
