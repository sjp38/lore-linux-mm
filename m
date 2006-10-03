Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k93IIeIe019145
	for <linux-mm@kvack.org>; Tue, 3 Oct 2006 14:18:40 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k93IHPur489398
	for <linux-mm@kvack.org>; Tue, 3 Oct 2006 12:17:25 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k93IHPbt015668
	for <linux-mm@kvack.org>; Tue, 3 Oct 2006 12:17:25 -0600
Subject: Re: 2.6.18-mm3
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20061003110136.3a572578.akpm@osdl.org>
References: <20061003001115.e898b8cb.akpm@osdl.org>
	 <1159897051.9569.0.camel@dyn9047017100.beaverton.ibm.com>
	 <20061003110136.3a572578.akpm@osdl.org>
Content-Type: text/plain
Date: Tue, 03 Oct 2006 11:16:57 -0700
Message-Id: <1159899417.9569.11.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2006-10-03 at 11:01 -0700, Andrew Morton wrote:
...
> 
> http://userweb.kernel.org/~akpm/badari2.bz2 is a rollup against 2.6.18
> which omits the various zone changes.  Can you see if that also fails?

I can't compile this. I found the problem with -mm3 (I sent the patch
already). Networking is working fine now on -mm3. So I don't bother
trying this for now ?

  CHK     include/linux/version.h
  CHK     include/linux/utsrelease.h
  CC      arch/x86_64/kernel/asm-offsets.s
In file included from arch/x86_64/kernel/asm-offsets.c:7:
include/linux/crypto.h:20:24: error: asm/atomic.h: No such file or
directory
In file included from include/linux/sched.h:4,
                 from include/linux/module.h:9,
                 from include/linux/crypto.h:21,
                 from arch/x86_64/kernel/asm-offsets.c:7:
include/linux/auxvec.h:4:24: error: asm/auxvec.h: No such file or
directory
In file included from include/linux/module.h:9,
                 from include/linux/crypto.h:21,
                 from arch/x86_64/kernel/asm-offsets.c:7:
include/linux/sched.h:44:36: error: asm/param.h: No such file or
directory


Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
