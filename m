Message-Id: <200412141811.iBEIBM922032@mail.osdl.org>
Subject: Re: Automated performance testing system was Re: Text form for STP tests 
In-Reply-To: Your message of "Mon, 13 Dec 2004 19:02:46 -0200."
             <20041213210246.GA27473@logos.cnet>
Date: Tue, 14 Dec 2004 10:11:22 -0800
From: Cliff White <cliffw@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org, stp-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

> On Mon, Dec 13, 2004 at 08:22:26AM -0800, cliff white wrote:
> > On Mon, 13 Dec 2004 09:42:23 -0200
> > Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
> > 
> > > On Wed, Dec 01, 2004 at 12:04:09PM -0800, Cliff White wrote:
> > > > > On Wed, Dec 01, 2004 at 10:28:24AM -0800, Cliff White wrote:
> > > > > > > Linux-MM fellows,
[snip]
> ork
> > > > for all tests - some of the kits still needs some patching..
> > > > cliffw
> > > 
> > > Any news on the automatic test series scripts Cliff ? 
> > > 
> > > Haven't seen any results yet.
> > > 
> > I ran a set for 2.6.10-rc3, PLM 3957, some results here:
> >  http://www.osdl.org/projects/26lnxstblztn/results/
> > Or by doing this:
> > http://www.osdl.org/lab_activities/kernel_testing/stp/display_test_requests
> ?d_patch_id%3Astring%3Aignore_empty=3957&op=Search
> > 
> > Marcelo, do you want me to submit the tests under your user id?
> > That would make searching for results eaiser. 
> 
> Cliff, 
> 
> How have you started these tests? I dont to run LTP for example.

We have a master script that checks kernel.org and bkbits.net for new
stuff ( run by cron ) If the master script sees new checkins that
match our regexp, it automagically kicks off the series of tests you 
requested. That covers the base,etc. 


> 
> I would like to be able to select two different patch ID's and run them from 
> the web
> interface, on a set of benchmarks vs memory size ranges vs nrCPUs (you alread
> y do 
> different number of CPUs on those series of tests I see), as we talked.
> Not just me, every developer doing performance testing :)

The current web requires you to set this up by hand,one test at a time.
We're working on some command line tools to replace the web, but
we're also thinking about another rev of the web interface, so the 
comments are helpful.
> 
> And then generate the graphs for the results of one patchID vs another. 
> 
> On reaim for example it would be nice to have graphs of global jobs per minut
> e vs 
> memory size, with a different colors for each patch ID. 
Okay.
> 
> Maybe we can even fit results for different nrCPUS on the same graph 
> with line types (with symbols like triangle, square, to differentiate).
> But then it might become too polluted to easily visualize, but maybe not.

I haven't had time to figure out fancy gnuplottage..that sounds neat.
> 
> Can you make the scripts which you are using for graphic generation and the
> gnuplot configuration files available? So I can play around with them.
> I want to help with that.
> 
> Another question: Is the source for reaim available? 
Of course, we're the Open Source Development Lab :)
Reaim:
bk bk://developer.osdl.org/reaim
or SF, tarballs
http://sourceforge.net/projects/re-aim-7/

any of the STP tests can be found as:
bk bk://developer.osdl.org/stp-test/<testname>
so 
bk://developer.osdl.org/stp-test/reaim

> 
> I see you're already generating the graphs for vmstat/iostat and user/system 
> time.
> 
> Thats really nice.
Those bits are in a Perl module that a few tests re-use.

> 
cliffw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
