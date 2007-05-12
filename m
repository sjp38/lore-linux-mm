Date: Sat, 12 May 2007 01:14:54 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] mm: swap prefetch improvements
Message-Id: <20070512011454.50ba68a5.pj@sgi.com>
In-Reply-To: <200705121728.34987.kernel@kolivas.org>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
	<200705121516.00070.kernel@kolivas.org>
	<20070511225111.fee05bb9.pj@sgi.com>
	<200705121728.34987.kernel@kolivas.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: nickpiggin@yahoo.com.au, ray-lk@madrabbit.org, mingo@elte.hu, ck@vds.kolivas.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Ummm this is what I've been saying for over a year now but noone has been 
> listening.

Well ... if there is a problem using prefetch and cpusets together,
it doesn't look like the two of us are going to find it.

I should probably look at your patch to answer this next question,
but being a lazy retard, I'll just ask.  Is there a way, on a running
system that has your prefetch patch configured in, to disable prefetch
-- perhaps writing to some magic /proc file or something?

If so, then how about you just remove the lines in the patch that
disable prefetch on kernels configured with CPUSETS, and we charge
ahead allowing both at the same time?

If some day in the future I find something about prefetch that harms
the HPC NUMA loads I care about, then I can just dynamically disable
prefetch.

If someone ever uncovers a real problem with prefetch and cpusets,
then we will deal with it then.

As to whether your patch is otherwise (other than cpusets) worthy
of further acceptance, that I will have to leave up to those who are
competent to make such judgements.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
