Date: Mon, 13 Dec 2004 09:42:23 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: Automated performance testing system was Re: Text form for STP tests
Message-ID: <20041213114223.GH24597@logos.cnet>
References: <20041201131607.GH2250@dmt.cyclades> <200412012004.iB1K49n23315@mail.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200412012004.iB1K49n23315@mail.osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Cliff White <cliffw@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Dec 01, 2004 at 12:04:09PM -0800, Cliff White wrote:
> > On Wed, Dec 01, 2004 at 10:28:24AM -0800, Cliff White wrote:
> > > > Linux-MM fellows,
> > > > 
> > > > I've been talking to Cliff about the need for a set of benchmarks,
> > > > covering as many different workloads as possible, for developers to have a 
> > > > better notion of impact on performance changes. 
> > > > 
> [snip]
> > > robots are running this test series against linux-2.6.7 ( for history data )
> > > There will need to be some adjustments - some of these tests will no doubt
> > > fail for reasons of script error or configuration ( i see already kernbench will 
> > > have to be redunced for 1-cpu systems, as it runs > 13.5 hours :( )
> > > 
> > > And, the second part of the automation is already done, but needs input.
> > > I can aim this test battery at any kernel patch, where 'any kernel patch'
> > > is identified by a regexp. What kernels do you want this against? 
> > 
> > The most recent 2.6.10-rc2 and 2.6.10-rc2-mm in STP.
> > 
> > Will this be available through the web interface? 
> 
> Yes, the results should be visible. If something looks wrongs, email.
> the 'advanced search' bit needs some test-specific fixes, and may not work
> for all tests - some of the kits still needs some patching..
> cliffw

Any news on the automatic test series scripts Cliff ? 

Haven't seen any results yet.

Thanks 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
