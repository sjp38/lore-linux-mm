Message-ID: <3D764A9F.B296F6C0@zip.com.au>
Date: Wed, 04 Sep 2002 11:02:08 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: 2.5.33-mm1
References: <3D75CD24.AF9B769B@zip.com.au> <1031159814.23852.21.camel@plars.austin.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Larson <plars@linuxtestproject.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Paul Larson wrote:
> 
> I havn't tried this with stock 2.5.33 or 2.5.33-mm2 yet, but I was
> trying the old fork07 ltp test and got a problem when I was testing
> mm1.  The fork bomb part of that test is now in the fork12 test in LTP
> and is not run by runalltests anymore due to the recent kernel changes.
> Here's the ksymoops output for now, and I'll see about trying to
> reproduce it.
> 
> ..
> >>EIP; c0131ef0 <kmem_shrink_slab+40/b0>   <=====


hm.  We seem to have a corrupted slabp->list.  I don't recall any
slab fixes post 2.3.33-mm1.  hm.

Questions, please: how much physical memory, how many CPUs?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
