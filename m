Subject: Re: [PATCH] change zonelist order v5 [1/3] implements zonelist
	order selection
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070509102018.8aaf21ed.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070508201401.8f78ec37.kamezawa.hiroyu@jp.fujitsu.com>
	 <20070508201642.c63b3f65.kamezawa.hiroyu@jp.fujitsu.com>
	 <1178643985.5203.27.camel@localhost>
	 <Pine.LNX.4.64.0705081021340.9446@schroedinger.engr.sgi.com>
	 <1178645622.5203.53.camel@localhost>
	 <Pine.LNX.4.64.0705081104180.9941@schroedinger.engr.sgi.com>
	 <1178656627.5203.84.camel@localhost>
	 <20070509092912.3140bb78.kamezawa.hiroyu@jp.fujitsu.com>
	 <20070508175855.b126caf7.akpm@linux-foundation.org>
	 <20070509102018.8aaf21ed.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Wed, 09 May 2007 09:55:43 -0400
Message-Id: <1178718943.5047.20.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, clameter@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ak@suse.de, jbarnes@virtuousgeek.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-05-09 at 10:20 +0900, KAMEZAWA Hiroyuki wrote:
> On Tue, 8 May 2007 17:58:55 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Wed, 9 May 2007 09:29:12 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > On Tue, 08 May 2007 16:37:06 -0400
> > > Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> > > 
> > > > > You probably need a 
> > > > > configuration with a couple of nodes. Maybesomething less symmetric than 
> > > > > Kame? I.e. have 4GB nodes and then DMA32 takes out a sizeable chunk of it?
> > > > > 
> > > > 
> > > > I tested on a 2 socket, 4GB Opteron blade.  All memory is either DMA32
> > > > or DMA.  I added some ad hoc instrumentation to the build_zonelist_*
> > > > functions to see what's happening.  I have verified that the patches
> > > > appear to build the zonelists correctly:
> > > > 
> > > Thank you. good news.
> > > 
> > 
> > I'm still cowering in fear of these patches, btw.
> > 
> Hmm, the patches looks unclear ? 
> 
> > Please keep testing and sending them ;)
> > 
> Okay. but it seems I need other testers...
> 
> I wonder I should drop sysctl of this patch and just support boot option
> in next version.

I think the system still need to be able to rebuild the zonelists at
run-time in response to memory hotplug [someday, maybe?].  And for now,
the sysctl is very useful for testing.  And, it does avoid a
reboot--quite expensive, timewise, on large platforms--should one find
that the default order is not appropriate.  

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
