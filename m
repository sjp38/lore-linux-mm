Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id E7BEC6B0044
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 13:44:20 -0400 (EDT)
Date: Fri, 21 Sep 2012 10:44:19 -0700
From: Larry Bassel <lbassel@codeaurora.org>
Subject: Re: steering allocations to particular parts of memory
Message-ID: <20120921174418.GD4018@labbmf01-linux.qualcomm.com>
References: <20120907182715.GB4018@labbmf01-linux.qualcomm.com>
 <20120911093407.GH11266@suse.de>
 <20120912212829.GC4018@labbmf01-linux.qualcomm.com>
 <20120913083443.GS11266@suse.de>
 <9e3b0e01-836d-49d3-8aed-9ed9df6c1cfa@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9e3b0e01-836d-49d3-8aed-9ed9df6c1cfa@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Mel Gorman <mgorman@suse.de>, Larry Bassel <lbassel@codeaurora.org>, linux-mm@kvack.org, Konrad Wilk <konrad.wilk@oracle.com>

On 17 Sep 12 12:40, Dan Magenheimer wrote:
> Hi Larry --
> 
> Sorry I missed seeing you and missed this discussion at Linuxcon!
> 
> > based on transcendent memory (which I am somewhat familiar
> > with, having built something based upon it which can be used either
>         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> > as contiguous memory or as clean cache) might work, but
> 
> That reminds me... I never saw this code posted on linux-mm
> or lkml or anywhere else.  Since this is another interesting
> use of tmem/cleancache/frontswap, it might be good to get
> your work into the kernel or at least into some other public
> tree.  Is your code post-able? (re original thread:
> http://www.spinics.net/lists/linux-mm/msg24785.html )

This was done on a 3.0 base (the tmem/zcache was from 3.1) a while back.

Due to the fact that 1) although some benchmarks improved,
very large file system writes suffered performance degradation
(measured with lmdd), 2) it appeared that supporting FAT
(or other filesystems where blocksize != pagesize) would be
difficult and 3) in many use cases we couldn't fill the carved
out FMEM regions with enough cleancache (so memory was still
being "wasted") as well as the fact that there was some functionality
we hadn't yet implemented (mainly supporting non-compressed FMEM) and
that the code would need to be ported forward to our 3.4 source
base, management decided to put this project on the back burner.

Therefore I don't believe I have any relevant code to post
(unless the project is revived and ported to a current source base).

Larry

-- 
The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
