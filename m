Message-Id: <200412012004.iB1K49n23315@mail.osdl.org>
Subject: Re: Automated performance testing system was Re: Text form for STP tests 
In-Reply-To: Your message of "Wed, 01 Dec 2004 11:16:07 -0200."
             <20041201131607.GH2250@dmt.cyclades>
Date: Wed, 01 Dec 2004 12:04:09 -0800
From: Cliff White <cliffw@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Wed, Dec 01, 2004 at 10:28:24AM -0800, Cliff White wrote:
> > > Linux-MM fellows,
> > > 
> > > I've been talking to Cliff about the need for a set of benchmarks,
> > > covering as many different workloads as possible, for developers to have a 
> > > better notion of impact on performance changes. 
> > > 
[snip]
> > robots are running this test series against linux-2.6.7 ( for history data )
> > There will need to be some adjustments - some of these tests will no doubt
> > fail for reasons of script error or configuration ( i see already kernbench will 
> > have to be redunced for 1-cpu systems, as it runs > 13.5 hours :( )
> > 
> > And, the second part of the automation is already done, but needs input.
> > I can aim this test battery at any kernel patch, where 'any kernel patch'
> > is identified by a regexp. What kernels do you want this against? 
> 
> The most recent 2.6.10-rc2 and 2.6.10-rc2-mm in STP.
> 
> Will this be available through the web interface? 

Yes, the results should be visible. If something looks wrongs, email.
the 'advanced search' bit needs some test-specific fixes, and may not work
for all tests - some of the kits still needs some patching..
cliffw
> 
> Thanks again Cliff
> 
> > I've heard mention of 'baseline' - we call this baseline:
> > 
> > /^(patch|linux)-\d+\.\d+\.\d+$/
> > 
> > ( starts with 'patch' or 'linux', then '-' followed by three decimals ) 
> > 
> > cliffw
> 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
