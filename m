From: Dimitri Sivanich <sivanich@sgi.com>
Message-Id: <200405211541.i4LFfpar001544@fsgi142.americas.sgi.com>
Subject: Slab cache reap and CPU availability
Date: Fri, 21 May 2004 10:41:50 -0500 (CDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

I have a fairly general question about the slab cache reap code.

In running realtime noise tests on the 2.6 kernels (spinning to detect periods
of CPU unavailability to RT threads) on an IA/64 Altix system, I have found the
cache_reap code to be the source of a number of larger holdoffs (periods of
CPU unavailability).  These can last into the 100's of usec on 1300 MHz CPUs.
Since this code runs periodically every few seconds as a timer softirq on all
CPUs, holdoffs can occur frequently.

Has anyone looked into less interruptive alternatives to running cache_reap
this way (for the 2.6 kernel), or maybe looked into potential optimizations
to the routine itself?


Thanks in advance,

Dimitri Sivanich <sivanich@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
