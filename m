Date: Mon, 11 Sep 2006 09:35:49 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: -mm numa perf regression
Message-Id: <20060911093549.a553cfe5.akpm@osdl.org>
In-Reply-To: <45057055.7070003@shadowen.org>
References: <20060901105554.780e9e78.akpm@osdl.org>
	<Pine.LNX.4.64.0609011125110.19863@schroedinger.engr.sgi.com>
	<44F88236.10803@google.com>
	<Pine.LNX.4.64.0609011231300.20077@schroedinger.engr.sgi.com>
	<44F8949E.4010308@google.com>
	<Pine.LNX.4.64.0609011314590.20312@schroedinger.engr.sgi.com>
	<44F8970F.2050004@google.com>
	<Pine.LNX.4.64.0609011331240.20357@schroedinger.engr.sgi.com>
	<44F8BB87.7050402@shadowen.org>
	<Pine.LNX.4.64.0609020658290.22978@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0609071116290.16838@schroedinger.engr.sgi.com>
	<45017C95.90502@shadowen.org>
	<Pine.LNX.4.64.0609081132200.23089@schroedinger.engr.sgi.com>
	<45057055.7070003@shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org
Cc: Christoph Lameter <clameter@sgi.com>, Martin Bligh <mbligh@google.com>, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>

On Mon, 11 Sep 2006 15:19:01 +0100
Andy Whitcroft <apw@shadowen.org> wrote:

> Christoph Lameter wrote:
> > On Fri, 8 Sep 2006, Andy Whitcroft wrote:
> > 
> >>> I have not heard back from you on this issue. It would be good to have 
> >>> some more data on this one.
> >> Sorry I submitted the tests and the results filtered out to TKO, and
> >> then I forgot to check them.  Looking at the graph backing this out has
> >> had no effect.  As I think we'd expect from what comes below.
> >>
> >> What next?
> > 
> > Get me the promised data? /proc/zoneinfo before and after the run. 
> > /proc/meminfo and /sys/devices/system/node/node*/* would be helpful.
> 
> Sorry for the delay, the relevant files wern't all being preserved.
> Fixed that up and reran things.  The results you asked for are available
> here:
> 
>     http://www.shadowen.org/~apw/public/debug-moe-perf/47138/
> 
> Just having a quick look at the results, it seems that they are saying
> that all of our cpu's are in node 0 which isn't right at all.  The
> machine has 4 processors per node.
> 
> I am sure that would account for the performance loss.  Now as to why ...
> 
> > Is there a way to remotely access the box?
> 
> Sadly no ... I do have direct access to test on the box but am not able
> to export it.
> 
> I've also started a bisection looking for it.  Though that will be some
> time yet as I've only just dropped the cleaver for the first time.
> 

I've added linux-mm.  Can we please keep it on-list.  I have a vague suspicion
that your bisection will end up pointing at one Mel Gorman.  Or someone else.
But whoever it is will end up wondering wtf is going on.

I don't understand what you mean by "all of our cpu's are in node 0"?  
http://www.shadowen.org/~apw/public/debug-moe-perf/47138/sys/devices/system/node.after/node0/
and
http://www.shadowen.org/~apw/public/debug-moe-perf/47138/sys/devices/system/node.before/node0/
look the same..  It depends what "before" and "after" mean, I guess...

Do we have full dmesg output for both 2.6.18-rc6-mm1 and 2.6.18-rc6?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
