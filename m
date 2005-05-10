Date: Tue, 10 May 2005 21:58:54 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Fw: [Bug 4520] New: /proc/*/maps fragments too quickly compared to
Message-ID: <20050510195854.GA27755@elte.hu>
References: <20050510115818.0828f5d1.akpm@osdl.org> <200505101934.j4AJYfg26483@unix-os.sc.intel.com> <20050510124357.2a7d2f9b.akpm@osdl.org> <17025.4213.255704.748374@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <17025.4213.255704.748374@gargle.gargle.HOWL>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Wolfgang Wander <wwc@rentec.com>
Cc: Andrew Morton <akpm@osdl.org>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, arjanv@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Wolfgang Wander <wwc@rentec.com> wrote:

> I volunteer to do the testing - just the test I got from Ingo did
> not show any timing difference for either of the three solutions:
> 
> a) use free_cache
> b) disable free_cache
> c) use my maybe improved and maybe much too complex free_cache
> 
> The test_str02.c I got only ran up to 1300 threads on my machine (8GB 
> dual x86_64) and Ingo expected it to go up to 20000.

do something like 'ulimit -s 128k' to reduce the thread stack sizes, to 
be able to run more threads. You are running an x86 (not x64) kernel to 
test, right?

	Ingo
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
