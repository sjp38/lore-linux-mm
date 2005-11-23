Subject: Re: [PATCH]: Free pages from local pcp lists under tight memory
	conditions
From: Rohit Seth <rohit.seth@intel.com>
In-Reply-To: <Pine.LNX.4.62.0511231325150.23433@schroedinger.engr.sgi.com>
References: <20051122161000.A22430@unix-os.sc.intel.com>
	 <Pine.LNX.4.62.0511231128090.22710@schroedinger.engr.sgi.com>
	 <1132775194.25086.54.camel@akash.sc.intel.com>
	 <20051123115545.69087adf.akpm@osdl.org>
	 <1132779605.25086.69.camel@akash.sc.intel.com>
	 <Pine.LNX.4.62.0511231325150.23433@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 23 Nov 2005 14:29:03 -0800
Message-Id: <1132784943.25086.87.camel@akash.sc.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2005-11-23 at 13:25 -0800, Christoph Lameter wrote:
> On Wed, 23 Nov 2005, Rohit Seth wrote:
> 
> > I thought Nick et.al came up with some of the constant values like batch
> > size to tackle the page coloring issue specifically.  In any case, I
> > think one of the key difference between 2.4 and 2.6 allocators is the
> > pcp list.  And even with the minuscule batch and high watermarks this is
> > helping ordinary benchmarks (by reducing the variation from run to run).
> 
> Could you share some benchmark results?
> 

Some components of cpu2k on 2.4 base kernels show in access of 40-50%
variation from run to run.  The same variations came down to about 10%
for 2.6 based kernels.   

-rohit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
