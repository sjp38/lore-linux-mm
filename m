Date: Fri, 15 Sep 2006 08:53:44 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
In-Reply-To: <20060915010622.0e3539d2.akpm@osdl.org>
Message-ID: <Pine.LNX.4.63.0609150843130.13918@chino.corp.google.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
 <20060914220011.2be9100a.akpm@osdl.org> <20060914234926.9b58fd77.pj@sgi.com>
 <20060915002325.bffe27d1.akpm@osdl.org> <20060915004402.88d462ff.pj@sgi.com>
 <20060915010622.0e3539d2.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Paul Jackson <pj@sgi.com>, clameter@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 15 Sep 2006, Andrew Morton wrote:

> David has fixed numa=fake (it was badly busted) and has been experimenting
> with a 3GB machine sliced into 64 "nodes".  So he can build containers
> whose memory allocation is variable in 40-odd-megabyte hunks.
> 

The 40-odd-megabyte hunks are for numa=fake=64 (63*48M + 1*47M on my 
machine).  I've gone as high as numa=fake=128 (127*24M + 1*23M).

> I _think_ it goes all the way up to getting oom-killed (David?).  The
> oom-killer appears to be doing the right thing - we don't want it to be
> killing processes which aren't inside the offending container.
> 

Yes, oomkiller will kill processes from within the offending cpuset.  I 
originally noticed it when I tried the kernel build by only giving it 64M.  
It's trivial to do with anything that mlocks the memory; my favorite: 
'usemem -m 2048 -n 2 -M' inside a cpuset configured for only 1G of memory 
with any number of batch jobs outside the cpuset that should, and never 
are, killed.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
