Message-ID: <3DACBD58.AAD8F0A@austin.ibm.com>
Date: Tue, 15 Oct 2002 20:14:00 -0500
From: Saurabh Desai <sdesai@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [patch] mmap-speedup-2.5.42-C3
References: <Pine.LNX.4.44.0210151438440.10496-100000@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@transmeta.com>, Andrew Morton <akpm@zip.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, NPT library mailing list <phil-list@redhat.com>
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> 
> the attached patch (against BK-curr) adds three new, threading related
> improvements to the VM.
> 
> the first one is an mmap inefficiency that was reported by Saurabh Desai.
> The test_str02 NPTL test-utility does the following: it tests the maximum
> number of threads by creating a new thread, which thread creates a new
> thread itself, etc. It basically creates thousands of parallel threads,
> which means thousands of thread stacks.

  Like to point out, test_str02 is a NGPT test program not NPTL.

 
> the patch was tested on x86 SMP and UP. Saurabh, can you confirm that this
> patch fixes the performance problem you saw in test_str02?
> 

  Yes, the test_str02 performance improved a lot using NPTL.
  However, on a side effect, I noticed that randomly my current telnet session
  was logged out after running this test. Not sure, why?  
  I applied your patch on 2.5.42 kernel and running glibc-2.3.1pre2.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
