Date: Wed, 1 Dec 2004 11:16:07 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: Automated performance testing system was Re: Text form for STP tests
Message-ID: <20041201131607.GH2250@dmt.cyclades>
References: <20041130004212.GB2310@dmt.cyclades> <200412011828.iB1ISOr04501@mail.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200412011828.iB1ISOr04501@mail.osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Cliff White <cliffw@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Dec 01, 2004 at 10:28:24AM -0800, Cliff White wrote:
> > Linux-MM fellows,
> > 
> > I've been talking to Cliff about the need for a set of benchmarks,
> > covering as many different workloads as possible, for developers to have a 
> > better notion of impact on performance changes. 
> > 
> > Usually when one does a change which affects performance, he/she runs one 
> > or two benchmarks with a limited amount of hardware configurations.
> > This is a very painful, boring and time consuming process, which can 
> > result in misinterpretation and/or limited understading of the results 
> > of such changes.
> > 
> > It is important to automate such process, with a set of benchmarks 
> > covering as wide as possible range of workloads, running on common 
> > and most used hardware variations.
> > 
> > OSDL's STP provides the base framework for this.
> > 
> [ snip ]
> > bonnie++
> > reaim (default, new_fserver, shared)
> > dbench_long
> > kernbench
> > tiobench
> > 
> > Each of these running one the following combinations:
> > 
> > 1CPU, 2CPU, 4CPU, 8CPU (4 variants).
> > 
> > total memory, half memory, a quarter of total memory (3 variants).
> > 
> > Thats 12 results for each benchmark."
> > 
> The configuration files to do these tests are now written, and the humble
> robots are running this test series against linux-2.6.7 ( for history data )
> There will need to be some adjustments - some of these tests will no doubt
> fail for reasons of script error or configuration ( i see already kernbench will 
> have to be redunced for 1-cpu systems, as it runs > 13.5 hours :( )
> 
> And, the second part of the automation is already done, but needs input.
> I can aim this test battery at any kernel patch, where 'any kernel patch'
> is identified by a regexp. What kernels do you want this against? 

The most recent 2.6.10-rc2 and 2.6.10-rc2-mm in STP.

Will this be available through the web interface? 

Thanks again Cliff

> I've heard mention of 'baseline' - we call this baseline:
> 
> /^(patch|linux)-\d+\.\d+\.\d+$/
> 
> ( starts with 'patch' or 'linux', then '-' followed by three decimals ) 
> 
> cliffw
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
