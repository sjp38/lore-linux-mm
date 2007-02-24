Date: Sat, 24 Feb 2007 14:28:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: SLUB: The unqueued Slab allocator
Message-Id: <20070224142835.4c7a3207.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0702221040140.2011@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702212250271.30485@schroedinger.engr.sgi.com>
	<p73hctecc3l.fsf@bingen.suse.de>
	<Pine.LNX.4.64.0702221040140.2011@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: andi@firstfloor.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Feb 2007 10:42:23 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> > > G. Slab merging
> > > 
> > >    We often have slab caches with similar parameters. SLUB detects those
> > >    on bootup and merges them into the corresponding general caches. This
> > >    leads to more effective memory use.
> > 
> > Did you do any tests on what that does to long term memory fragmentation?
> > It is against the "object of same type have similar livetime and should
> > be clustered together" theory at least.
> 
> I have done no tests in that regard and we would have to assess the impact 
> that the merging has to overall system behavior.
> 
>From a viewpoint of a crash dump user, this merging will make crash dump
investigation very very very difficult.
So please avoid this merging if the benefit is nog big.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
