Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id AA6BD6B0038
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 23:19:30 -0500 (EST)
Received: by mail-ob0-f179.google.com with SMTP id va2so3562368obc.24
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 20:19:30 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id bq7si377971obb.79.2014.11.18.20.19.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Nov 2014 20:19:29 -0800 (PST)
Message-ID: <546C18C5.5090508@oracle.com>
Date: Tue, 18 Nov 2014 23:12:53 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: shmem: freeing mlocked page
References: <545C4A36.9050702@oracle.com>	<5466142C.60100@oracle.com>	<20141118135843.bd711e95d3977c74cf51d803@linux-foundation.org>	<546C1202.1020502@oracle.com> <20141118195656.f80ff650.akpm@linux-foundation.org>
In-Reply-To: <20141118195656.f80ff650.akpm@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>, Jens Axboe <axboe@kernel.dk>

On 11/18/2014 10:56 PM, Andrew Morton wrote:
>> Trinity can't really log anything because attempts to log syscalls slow everything
>> > down to a crawl to the point nothing reproduces.
> Ah.  I was thinking that it could be worked out by looking at the
> trinity source around where it calls splice().  But I suspect that
> doesn't make sense if trinity just creates a zillion threads each of
> which sprays semi-random syscalls at the kernel(?).

I think Dave would agree here that this is a rather accurate description
of Trinity :)

>> > I've just looked at that trace above, and got a bit more confused. I didn't think
>> > that you can mlock page cache. How would a user do that exactly?
> mmap it then mlock it!  The kernel will fault everything in for you
> then pin it down.

But that's a pipe buffer, I didn't think userspace can mmap pipes? I have
some reading to do.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
