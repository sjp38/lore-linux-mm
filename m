Date: Tue, 22 Mar 2005 15:10:08 -0800
From: Paul Jackson <pj@engr.sgi.com>
Subject: Re: [Patch] cpusets policy kill no swap
Message-Id: <20050322151008.4a259486.pj@engr.sgi.com>
In-Reply-To: <20050319225855.475e4167.akpm@osdl.org>
References: <20050320014847.16310.53697.sendpatchset@sam.engr.sgi.com>
	<20050319225855.475e4167.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: pj@sgi.com, mort@sgi.com, linux-mm@kvack.org, emery@sgi.com, bron@sgi.com, Simon.Derr@bull.net, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Thanks Andrew - you're right.  Drop this patch in /dev/null.

 * I will look around for some way that user code can
   detect that a task has provoked swapping, or propose
   a small patch, perhaps to /proc, for that, if need be.

 * I agree that the action, killing a task or whatever, can
   and should be instigated by user level code.  The kernel
   provides the essential mechanisms; user code decides the
   policy, and elaborates the mechanisms.

 * I'm concerned that polling some /proc state will either be too
   wasteful of cycles (if we poll fast) or have too much delay to
   trigger (if we poll slow).  Though I need some real numbers,
   to see if this is a real problem.  It was definitely a problem
   in a past life, but that may not apply here.  The Linux 2.6
   swapper is much more NUMA friendly.

   Note, however, that something like rlimit, used to impose
   other limits on task resource consumption, depends on specific
   kernel hooks to catch the violation (using too much memory,
   say) rather than insisting that user space code scan /proc
   information looking for violators.  The former is just way
   too efficient compared to the latter.

 * I'm still casting about for appropriate mechanisms (if polling
   some /proc data is not adequate) to:
    1) enable user space code to control some kernel trigger
       that fires when a task causes more swapping than the
       setting allows (something like rlimit?), and
    2) an economical mechanism for the kernel to deliver such
       events back to user space (call_usermodehelper or
       satisfying a read on a special file?).

If you, or any lurker, has further thoughts, they would be
welcome.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@engr.sgi.com> 1.650.933.1373, 1.925.600.0401
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
