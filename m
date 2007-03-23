Date: Thu, 22 Mar 2007 20:50:38 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: Subject: [PATCH RESEND 1/1] cpusets/sched_domain reconciliation
Message-Id: <20070322205038.6009989f.pj@sgi.com>
In-Reply-To: <46033311.1000101@yahoo.com.au>
References: <20070322231559.GA22656@sgi.com>
	<46033311.1000101@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: cpw@sgi.com, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick also wrote:
> The problem was that Paul didn't think it followed cpus_exclusive
> correctly, and I don't think we ever got to the point of giving it
> a rigourous definition.

>From Documentation/cpusets.txt:

 - A cpuset may be marked exclusive, which ensures that no other
   cpuset (except direct ancestors and descendents) may contain
   any overlapping CPUs or Memory Nodes.

This seems like the same definition to me as you gave, and I just
agreed to in my previous post a few minutes ago.  It seems rigourous
to me ;>.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
