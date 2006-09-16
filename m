Date: Sat, 16 Sep 2006 04:48:47 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
Message-Id: <20060916044847.99802d21.pj@sgi.com>
In-Reply-To: <20060915002325.bffe27d1.akpm@osdl.org>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
	<20060914220011.2be9100a.akpm@osdl.org>
	<20060914234926.9b58fd77.pj@sgi.com>
	<20060915002325.bffe27d1.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: clameter@sgi.com, linux-mm@kvack.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

Andrew, replying to pj:
> > We shouldn't be heavily tuning for this case, and I am not aware of any
> > real world situations where real users would have reasonably determined
> > otherwise, had they had full realization of what was going on.
> 
> gotcha ;)

In the thrill of the hunt, I overlooked one itsy bitsy detail.

This load still seems a tad artificial to me.  What real world load
would run with 2/3's of the nodes having max'd out memory?

I'm suspecting that its worth some effort, to improve it, but not worth
major effort to get ideal performance.

I'm still open to more persuasion however.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
