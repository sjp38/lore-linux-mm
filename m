Message-Id: <5.2.0.9.2.20030610125606.00cd04a0@pop.gmx.net>
Date: Tue, 10 Jun 2003 13:31:32 +0200
From: Mike Galbraith <efault@gmx.de>
Subject: Re: 2.5.70-mm6
In-Reply-To: <20030610092048.GB26348@holomorphy.com>
References: <Pine.LNX.4.51.0306101052160.14891@dns.toxicfilms.tv>
 <46580000.1055180345@flay>
 <Pine.LNX.4.51.0306092017390.25458@dns.toxicfilms.tv>
 <51250000.1055184690@flay>
 <Pine.LNX.4.51.0306092140450.32624@dns.toxicfilms.tv>
 <20030609200411.GA26348@holomorphy.com>
 <Pine.LNX.4.51.0306101052160.14891@dns.toxicfilms.tv>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Maciej Soltysiak <solt@dns.toxicfilms.tv>, "Martin J. Bligh" <mbligh@aracnet.com>, Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

At 02:20 AM 6/10/2003 -0700, William Lee Irwin III wrote:
>At some point in the past, I wrote:
> >> How about one or the other of these two? (not both at once, though,
> >> they appear to clash).
>
>On Tue, Jun 10, 2003 at 10:54:55AM +0200, Maciej Soltysiak wrote:
> > Success, no audio skipps with galbraith.patch and mm6.

(victim of fast hw methinks.  dog slow old isa card will probably work fine)

>Mike, any chance you can turn your series of patches into one that
>applies atop mingo's intra-timeslice priority preemption patch? If
>not, I suppose someone else could.

I've never seen it.  Is this the test-starve fix I heard mentioned on lkml 
once?

>There also appears to be some kind of issue with using monotonic_clock()
>with timer_pit as well as some locking overhead concerns. Something
>should probably be done about those things before trying to merge the
>fine-grained time accounting patch.

Ingo had me measure impact with lat_ctx, and it wasn't very encouraging 
(and my box is UP).  I'm not sure that I wasn't seeing some cache effects 
though, because the numbers jumped around quite a bit.  Per Ingo, the 
sequence lock change will greatly improve scalability.  Doing anything 
extra in that path is going to cost some pain though, so I'm trying to 
figure out a way to do something ~similar.  (ala perfect is the enemy of 
good mantra).

wrt pit, yeah, that diff won't work if you don't have a tsc.  If something 
like it were used, it'd have to have ifdefs to continue using 
jiffies.  (the other option being only presentable on April 1:)

         -Mike 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
