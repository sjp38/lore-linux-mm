Date: Thu, 1 Dec 2005 06:44:46 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH]: Free pages from local pcp lists under tight memory
 conditions
Message-Id: <20051201064446.c87049ad.pj@sgi.com>
In-Reply-To: <1133306336.24962.47.camel@akash.sc.intel.com>
References: <20051122161000.A22430@unix-os.sc.intel.com>
	<Pine.LNX.4.62.0511231128090.22710@schroedinger.engr.sgi.com>
	<1132775194.25086.54.camel@akash.sc.intel.com>
	<20051123115545.69087adf.akpm@osdl.org>
	<1132779605.25086.69.camel@akash.sc.intel.com>
	<20051123190237.3ba62bf0.pj@sgi.com>
	<1133306336.24962.47.camel@akash.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rohit Seth <rohit.seth@intel.com>
Cc: akpm@osdl.org, clameter@engr.sgi.com, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, steiner@sgi.com, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Rohit wrote:
> Can you please comment on the performance delta on the MPI workload
> because of this change in batch values. 

I can't -- all I know is what I read in Jack Steiner's posts
of April 5, 2005, referenced earlier in this thread.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
