Date: Tue, 10 Jun 2003 04:41:23 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.70-mm6
Message-ID: <20030610114123.GP15692@holomorphy.com>
References: <Pine.LNX.4.51.0306101052160.14891@dns.toxicfilms.tv> <46580000.1055180345@flay> <Pine.LNX.4.51.0306092017390.25458@dns.toxicfilms.tv> <51250000.1055184690@flay> <Pine.LNX.4.51.0306092140450.32624@dns.toxicfilms.tv> <20030609200411.GA26348@holomorphy.com> <Pine.LNX.4.51.0306101052160.14891@dns.toxicfilms.tv> <5.2.0.9.2.20030610125606.00cd04a0@pop.gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5.2.0.9.2.20030610125606.00cd04a0@pop.gmx.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <efault@gmx.de>
Cc: Maciej Soltysiak <solt@dns.toxicfilms.tv>, "Martin J. Bligh" <mbligh@aracnet.com>, Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

At 02:20 AM 6/10/2003 -0700, William Lee Irwin III wrote:
>> Mike, any chance you can turn your series of patches into one that
>> applies atop mingo's intra-timeslice priority preemption patch? If
>> not, I suppose someone else could.

On Tue, Jun 10, 2003 at 01:31:32PM +0200, Mike Galbraith wrote:
> I've never seen it.  Is this the test-starve fix I heard mentioned on lkml 
> once?

No idea what the posted name was. What it does is obvious enough. It
was posted earlier in this thread.


At 02:20 AM 6/10/2003 -0700, William Lee Irwin III wrote:
>> There also appears to be some kind of issue with using monotonic_clock()
>> with timer_pit as well as some locking overhead concerns. Something
>> should probably be done about those things before trying to merge the
>> fine-grained time accounting patch.

On Tue, Jun 10, 2003 at 01:31:32PM +0200, Mike Galbraith wrote:
> Ingo had me measure impact with lat_ctx, and it wasn't very encouraging 
> (and my box is UP).  I'm not sure that I wasn't seeing some cache effects 
> though, because the numbers jumped around quite a bit.  Per Ingo, the 
> sequence lock change will greatly improve scalability.  Doing anything 
> extra in that path is going to cost some pain though, so I'm trying to 

Okay, so mitigating the hit to context switch is ongoing.


On Tue, Jun 10, 2003 at 01:31:32PM +0200, Mike Galbraith wrote:
> figure out a way to do something ~similar.  (ala perfect is the enemy of 
> good mantra).

\vomit{Next you'll be telling me worse is better.}


On Tue, Jun 10, 2003 at 01:31:32PM +0200, Mike Galbraith wrote:
> wrt pit, yeah, that diff won't work if you don't have a tsc.  If something 
> like it were used, it'd have to have ifdefs to continue using 
> jiffies.  (the other option being only presentable on April 1:)

The issue is the driver returning garbage; not having as good of
precision from hardware is no fault of the method. I'd say timer_pit
should just return jiffies converted to nanoseconds.

Also, I posted the "thud" fix earlier in this thread in addition to the
monotonic_clock() bits. AFAICT it mitigates (or perhaps even fixes) an
infinite priority escalation scenario.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
