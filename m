Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 4EA2E6B0098
	for <linux-mm@kvack.org>; Fri,  8 May 2009 18:20:55 -0400 (EDT)
Message-ID: <4A04B021.10004@redhat.com>
Date: Fri, 08 May 2009 18:20:17 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first class
 citizen
References: <20090430181340.6f07421d.akpm@linux-foundation.org>	<20090430215034.4748e615@riellaptop.surriel.com>	<20090430195439.e02edc26.akpm@linux-foundation.org>	<49FB01C1.6050204@redhat.com>	<20090501123541.7983a8ae.akpm@linux-foundation.org>	<20090503031539.GC5702@localhost>	<1241432635.7620.4732.camel@twins>	<20090507121101.GB20934@localhost>	<20090507151039.GA2413@cmpxchg.org>	<20090507134410.0618b308.akpm@linux-foundation.org>	<20090508081608.GA25117@localhost>	<20090508125859.210a2a25.akpm@linux-foundation.org> <20090508230045.5346bd32@lxorguk.ukuu.org.uk>
In-Reply-To: <20090508230045.5346bd32@lxorguk.ukuu.org.uk>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, hannes@cmpxchg.org, peterz@infradead.org, linux-kernel@vger.kernel.org, tytso@mit.edu, linux-mm@kvack.org, elladan@eskimo.com, npiggin@suse.de, cl@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

Alan Cox wrote:
>> The patch seems reasonable but the changelog and the (non-existent)
>> design documentation could do with a touch-up.
> 
> Is it right that I as a user can do things like mmap my database
> PROT_EXEC to get better database numbers by making other
> stuff swap first ?

Yes, but only if your SELinux policy allows you to
mmap something that's both executable and writable
at the same time.

> You seem to be giving everyone a "nice my process up" hack.

A user who wants to slow the system down has always
been able to do so.

I am not convinced that the potential disadvantages
of giving mapped referenced executable file pages an
extra round trip on the active file list outweighs
the advantages of doing so for normal workloads.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
