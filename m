Date: Thu, 27 Apr 2006 16:02:50 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 1/2 (repost)] mm: serialize OOM kill operations
Message-Id: <20060427160250.a72cae11.pj@sgi.com>
In-Reply-To: <20060427140921.249a00b0.akpm@osdl.org>
References: <200604271308.10080.dsp@llnl.gov>
	<20060427134442.639a6d19.pj@sgi.com>
	<20060427140921.249a00b0.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: dsp@llnl.gov, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@surriel.com, nickpiggin@yahoo.com.au, ak@suse.de
List-ID: <linux-mm.kvack.org>

Andrew wrote:
> Note that these will occupy the same machine word.

That's why I did it.  Yup.

> So they'll need
> locking.  (Good luck trying to demonstrate the race though!)

Oops.  Good catch.  Thanks, Andrew.

Probably solvable (lockable) but this line of thought is
getting to be more trouble than I suspect it's worth.

I'm still a little surprised that this per-mm 'oom_notify' bit
was needed to implement what I thought was a single, global
system wide oom killer serializer.

But I'm too ignorant and lazy, and too distracted by other
tasks, to actually think that surprise through.

Good luck with it, Dave.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
