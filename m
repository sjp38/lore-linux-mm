Date: Wed, 1 Nov 2006 16:27:26 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Page allocator: Single Zone optimizations
In-Reply-To: <20061101162221.f110b56a.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0611011625530.18497@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com>
 <20061027190452.6ff86cae.akpm@osdl.org> <Pine.LNX.4.64.0610271907400.10615@schroedinger.engr.sgi.com>
 <20061027192429.42bb4be4.akpm@osdl.org> <Pine.LNX.4.64.0610271926370.10742@schroedinger.engr.sgi.com>
 <20061027214324.4f80e992.akpm@osdl.org> <Pine.LNX.4.64.0610281743260.14058@schroedinger.engr.sgi.com>
 <20061028180402.7c3e6ad8.akpm@osdl.org> <Pine.LNX.4.64.0610281805280.14100@schroedinger.engr.sgi.com>
 <4544914F.3000502@yahoo.com.au> <20061101182605.GC27386@skynet.ie>
 <20061101123451.3fd6cfa4.akpm@osdl.org> <Pine.LNX.4.64.0611011255070.14406@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611012210290.29614@skynet.skynet.ie>
 <Pine.LNX.4.64.0611011522370.16073@schroedinger.engr.sgi.com>
 <20061101162221.f110b56a.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Mel Gorman <mel@skynet.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 1 Nov 2006, Andrew Morton wrote:

> > I think that choice is better than fiddling with the VM by adding 
> > additional zones which will introduce lots of other problems.
> 
> What lots of other problems?  64x64MB zones works good.

Read my earlier mail on this. Certainly you can make this work for a 
specialized load that does not use all kernel features.

> > Right. So the device needs to disengage and then move its structures.
> 
> I don't think we have a snowball's chance of making all kernel memory
> relocatable.  Or even a useful amount of it.

In the simplest case the device would close down free all of its memory 
and then start up again reallocating necessary memory?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
