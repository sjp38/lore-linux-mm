Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6CC4A6B025F
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 11:49:58 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id e7so38159307lfe.0
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 08:49:58 -0700 (PDT)
Received: from arcturus.aphlor.org (arcturus.ipv6.aphlor.org. [2a03:9800:10:4a::2])
        by mx.google.com with ESMTPS id zw9si19499783wjb.49.2016.07.29.08.49.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jul 2016 08:49:55 -0700 (PDT)
Date: Fri, 29 Jul 2016 11:49:29 -0400
From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: [4.7+] various memory corruption reports.
Message-ID: <20160729154929.GA30611@codemonkey.org.uk>
References: <20160729150513.GB29545@codemonkey.org.uk>
 <20160729151907.GC29545@codemonkey.org.uk>
 <CAPAsAGxDOvD64+5T4vPiuJgHkdHaaXGRfikFxXGHDRRiW4ivVQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPAsAGxDOvD64+5T4vPiuJgHkdHaaXGRfikFxXGHDRRiW4ivVQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Jul 29, 2016 at 06:21:12PM +0300, Andrey Ryabinin wrote:
 > 2016-07-29 18:19 GMT+03:00 Dave Jones <davej@codemonkey.org.uk>:
 > > On Fri, Jul 29, 2016 at 11:05:14AM -0400, Dave Jones wrote:
 > >  > I've just gotten back into running trinity on daily pulls of master, and it seems pretty horrific
 > >  > right now.  I can reproduce some kind of memory corruption within a couple minutes runtime.
 > >  >
 > >  > ,,,
 > >  >
 > >  > I'll work on narrowing down the exact syscalls needed to trigger this.
 > >
 > > Even limiting it to do just a simple syscall like execve (which fails most the time in trinity)
 > > triggers it, suggesting it's not syscall related, but the fact that trinity is forking/killing
 > > tons of processes at high rate is stressing something more fundamental.
 > >
 > > Given how easy this reproduces, I'll see if bisecting gives up something useful.
 > 
 > I suspect this is false positives due to changes in KASAN.
 > Bisection probably will point to
 > 80a9201a5965f4715d5c09790862e0df84ce0614 ("mm, kasan: switch SLUB to
 > stackdepot, enable memory quarantine for SLUB)"

good call. reverting that changeset seems to have solved it.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
