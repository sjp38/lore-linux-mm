Subject: Re: [PATCH 01/14] NUMA: Generic management of nodemasks for
	various purposes
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070731203203.2691ca59.akpm@linux-foundation.org>
References: <20070727194316.18614.36380.sendpatchset@localhost>
	 <20070727194322.18614.68855.sendpatchset@localhost>
	 <20070731192241.380e93a0.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0707311946530.6158@schroedinger.engr.sgi.com>
	 <20070731200522.c19b3b95.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0707312006550.22443@schroedinger.engr.sgi.com>
	 <20070731203203.2691ca59.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Wed, 01 Aug 2007 10:03:31 -0400
Message-Id: <1185977011.5059.36.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, ak@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Mel Gorman <mel@skynet.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-07-31 at 20:32 -0700, Andrew Morton wrote:
> On Tue, 31 Jul 2007 20:14:08 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:
> 
> > On Tue, 31 Jul 2007, Andrew Morton wrote:
> > 
> > > ooookay...   I don't think I want to be the first person who gets
> > > to do that, so I shall duck them for -mm2.

Sorry about not testing on i386 and such.  My only i386 is my laptop--my
"window to the world"--and I tend not to run experimental/development
kernels on it.  [I know, such little faith :-(].  I suppose I could
reconfigure an X86_64 system in the lab with hardware interleaved memory
and try a 32-bit kernel there.  I'll add that to my [ever growing] list
of things to explore...

> > > 
> > > I think there were updates pending anyway.   I saw several under-replied-to
> > > patches from Lee but it wasn't clear it they were relevant to these changes
> > > or what.
> > 
> > I have not seen those. We also have the issue with slab allocations 
> > failing on NUMAQ with its HIGHMEM zones. 
> > 

I think Andrew is referring to the "exclude selected nodes from
interleave policy" and "preferred policy fixups" patches.  Those are
related to the memoryless node patches in the sense that they touch some
of the same lines in mempolicy.c.  However, IMO, those patches shouldn't
gate the memoryless node series once the i386 issues are resolved.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
