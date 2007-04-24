Date: Tue, 24 Apr 2007 13:21:25 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: 2.6.21-rc7-mm1 on test.kernel.org
In-Reply-To: <20070424130601.4ab89d54.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0704241320540.13005@schroedinger.engr.sgi.com>
References: <20070424130601.4ab89d54.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Apr 2007, Andrew Morton wrote:

> Naturally, I can't reproduce it (no amd64 boxen).  A bisection search would
> be wonderful.

Cannot compile a UP x86_64 kernel

  LD      arch/x86_64/kernel/pcspeaker.o
  LD      arch/x86_64/kernel/built-in.o
  AS      arch/x86_64/kernel/head.o
  CC      arch/x86_64/kernel/head64.o
arch/x86_64/kernel/head64.c: In function 'x86_64_start_kernel':
arch/x86_64/kernel/head64.c:70: error: size of array 'type name' is 
negative
make[1]: *** [arch/x86_64/kernel/head64.o] Error 1
make: *** [arch/x86_64/kernel] Error 2
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
