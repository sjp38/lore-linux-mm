Date: Thu, 4 Jul 2002 13:06:31 -0400
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: Benchmarking Tool
Message-ID: <20020704130631.B21370@redhat.com>
References: <20020703060446.GA2560@SandStorm.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20020703060446.GA2560@SandStorm.net>; from abhi@kernelnewbies.org on Wed, Jul 03, 2002 at 11:34:46AM +0530
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Abhishek Nayani <abhi@kernelnewbies.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 03, 2002 at 11:34:46AM +0530, Abhishek Nayani wrote:
> 	There was a discussion about the current benchmarking tools being
> not suitable or sufficient for testing the performance of the Linux VMs.
> I am interested in writing one and would like to have your opinions on
> the matter. I would like to know what is missing in the current set of
> tools (lmbench, dbench..) and what is required. 

dbench essentially produces a random number for "performance", as it 
is overly dependent on small changes in timing, available memory and 
execution patterns.  lmbench doesn't really test the vm at all.  What 
is needed are a series of tests that represent the kinds of loads 
that various Linux users run.  This includes:

	- software development
	- scientific apps
	- desktop
	- various server workloads

Most of the time results are presented, they tend to be lacking in some 
areas -- much of the high end work being done on >8GB systems tends not 
to rerun tests on small systems to make sure behaviour isn't badly 
affected.  Of the cases listed above, the desktop workload is probably 
the most badly represented with current tests.

>From a few of the discussions at OLS, it became apparent that more 
important than the actual benchmarking tools is the collection of the 
results.  Common tests, like compiling the kernel, are useful metrics 
for noticing changes in kernel behaviour if all other aspects of the 
test environment are held constant, but only if we have a set of data 
to compare the results against.

		-ben
-- 
"You will be reincarnated as a toad; and you will be much happier."
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
