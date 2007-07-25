Subject: Re: [patch 00/12] NUMA: Memoryless node support V3
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1185372692.5604.22.camel@localhost>
References: <20070711182219.234782227@sgi.com>
	 <20070713151431.GG10067@us.ibm.com>
	 <Pine.LNX.4.64.0707130942030.21777@schroedinger.engr.sgi.com>
	 <1185310277.5649.90.camel@localhost>
	 <Pine.LNX.4.64.0707241402010.4773@schroedinger.engr.sgi.com>
	 <1185372692.5604.22.camel@localhost>
Content-Type: text/plain
Date: Wed, 25 Jul 2007 11:45:22 -0400
Message-Id: <1185378322.5604.43.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: kxr@sgi.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Bob Picco <bob.picco@hp.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-07-25 at 10:11 -0400, Lee Schermerhorn wrote:
> On Tue, 2007-07-24 at 14:04 -0700, Christoph Lameter wrote:
> > On Tue, 24 Jul 2007, Lee Schermerhorn wrote:
> <snip>
> > 
> > > I have tested your series, with Nish's and my patches in a
> > > memory-constrained config with all of the cpus on memoryless nodes and
> > > all of the memory in a cpu-less pseudo-node.  Seems to hold up fairly
> > > well under stress.  I did see a hang on Monday--test hung, very little
> > > free memory, pdflush just trickling out pages--but haven't been able to
> > > reproduce it.  Don't know what happened.
> > 
> > Hmm... Not good. Was that with a pre rc1 release? I got a hang here on a 
> > simulator that seems to be related to high res timers.
> 
> It was on 22-rc6-mm1.
> 
> >  
> > > I haven't had a chance to poke at it with memtoy to see how the
> > > interleave and hugepages work.  But, most folks don't use that, so I
> > > think it's appropriate for -mm.  
> > > 
> > > How should we proceed?  Shall I Ack the patches, mentioning the testing
> > > I've done and recommend inclusion in -mm?
> > 
> > Could you post the patchset with your acks or signoffs if you have made 
> > changes? Address them to Andrew, cc me and I will support merging of what 
> > you got. Note though that I think were are at the beginning of dealing 
> > with nodeless and per node memory use.
> 
> I'm rebasing to 23-rc1-mm1 right now.  Will do a quick test and repost.


!!! :-(  This is going to take longer than I thought.

1) ia64 build breakage due to ACPI_SLEEP -- have work around hack that
I'll send to Andrew as temp hot fix, but that's not the worst of it.

2) fails to boot with:

Unable to handle kernel paging request at virtual address a000400002000020
swapper[0]: Oops 11003706212352 [1]
Modules linked in:

Pid: 0, CPU 0, comm:              swapper
psr : 00001210084a2010 ifs : 8000000000000995 ip  : [<a0000001008a4df1>]    Not tainted
ip is at memmap_init_zone+0x271/0x2a0
unat: 0000000000000000 pfs : 0000000000000995 rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : 656960155aa595a9
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70433f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a0000001008a4de0 b6  : a000000100340240 b7  : a0000001008ba3a0
f6  : 1003e0000000000000000 f7  : 1003e0000000000000974
f8  : 1003e000000000000e6e0 f9  : 1003e00000000001cdc02
f10 : 1003e0000000000000005 f11 : 1003e0000000000012785
r1  : a000000100c088a0 r2  : 0000000000000000 r3  : 0000000000002492
r8  : 0000000000000002 r9  : a000000100a08fe0 r10 : e000000100360700
r11 : 0000000000000000 r12 : a00000010092fd20 r13 : a000000100928000
r14 : fffffffffffffffb r15 : 0000000000000002 r16 : e000000101ca8000
r17 : 0000000000000003 r18 : a000400002000018 r19 : 0000000000000000
r20 : a000000100b5de00 r21 : 0000000000000008 r22 : e000000101ca8000
r23 : 0000000000000001 r24 : 5fffffffffe4924a r25 : 0006db6d7fe4924a
r26 : 5ff9249280000000 r27 : 0000000db6bf924a r28 : 0006db5fc9250000
r29 : 0000000e27ff8ec0 r30 : 00000000713ffc76 r31 : 000000001c3fff1e
WARNING: at mm/page_alloc.c:1562 __alloc_pages()

... then hard hang.

------------
I'll go ahead with the patch rebase while trying to debug this.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
