Received: from [127.0.0.1] (helo=logos.cnet)
	by www.linux.org.uk with esmtp (Exim 4.33)
	id 1C7Pce-0002jr-C8
	for linux-mm@kvack.org; Wed, 15 Sep 2004 03:34:17 +0100
Date: Tue, 14 Sep 2004 21:50:13 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: [barry@disus.com: RE: OOM Killer problem since linux 2.6.8.1]
Message-ID: <20040915005013.GB491@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

FYI - yet another spurious OOM killer report.

----- Forwarded message from Barry Silverman <barry@disus.com> -----

From: Barry Silverman <barry@disus.com>
Date: Tue, 14 Sep 2004 20:56:05 -0400
To: 'Marcelo Tosatti' <marcelo.tosatti@cyclades.com>
In-Reply-To: <20040914224955.GA789@logos.cnet>
Subject: RE: OOM Killer problem since linux 2.6.8.1
Importance: Normal
X-MIMETrack: Itemize by SMTP Server on USMail/Cyclades(Release 6.5.1|January 21, 2004) at
 09/14/2004 16:53:06

Yes, I installed 2.6.8.1 - patched in 2.6.9-rc1, and then
2.6.9-rc1-mm5...

It is easily reproducible - and takes no more than a couple of minutes
to re-occur, so we should be able to trace it down.... 

-----Original Message-----
From: Marcelo Tosatti [mailto:marcelo.tosatti@cyclades.com] 
Sent: Tuesday, September 14, 2004 6:50 PM
To: Barry Silverman
Subject: Re: OOM Killer problem since linux 2.6.8.1


Hi Barry,

That was 2.6.9-rc1-mm5 correct?

I'll start looking into your problem tomorrow in more detail.

On Tue, Sep 14, 2004 at 08:19:24PM -0400, Barry Silverman wrote:
> Done - Let me kow if you need to meter something else....Log is below:
> 
> Sep 14 20:16:18 dhcpaq kernel: oom-killer: gfp_mask=0x1d2
> Sep 14 20:16:19 dhcpaq kernel: DMA per-cpu:
> Sep 14 20:16:19 dhcpaq kernel: cpu 0 hot: low 2, high 6, batch 1
> Sep 14 20:16:19 dhcpaq kernel: cpu 0 cold: low 0, high 2, batch 1
> Sep 14 20:16:19 dhcpaq kernel: Normal per-cpu:
> Sep 14 20:16:19 dhcpaq kernel: cpu 0 hot: low 12, high 36, batch 6
> Sep 14 20:16:19 dhcpaq kernel: cpu 0 cold: low 0, high 12, batch 6
> Sep 14 20:16:19 dhcpaq kernel: HighMem per-cpu: empty
> Sep 14 20:16:19 dhcpaq kernel:
> Sep 14 20:16:19 dhcpaq kernel: Free pages:         420kB (0kB HighMem)
> Sep 14 20:16:19 dhcpaq kernel: Active:27885 inactive:32 dirty:0
writeback:0
> unstable:0 free:105 slab:1027 mapped:27889 pagetables:177
> Sep 14 20:16:19 dhcpaq kernel: DMA free:44kB min:44kB low:88kB
high:132kB
> active:12384kB inactive:32kB present:16384kB pages_scanned:0
> all_unreclaimable? no
> Sep 14 20:16:19 dhcpaq kernel: protections[]: 0 0 0
> Sep 14 20:16:21 dhcpaq kernel: Normal free:376kB min:300kB low:600kB
> high:900kB active:99156kB inactive:96kB present:106496kB
pages_scanned:0
> all_unreclaimable? no
> Sep 14 20:16:21 dhcpaq kernel: protections[]: 0 0 0
> Sep 14 20:16:21 dhcpaq kernel: HighMem free:0kB min:128kB low:256kB
> high:384kB active:0kB inactive:0kB present:0kB pages_scanned:0
> all_unreclaimable? no
> Sep 14 20:16:21 dhcpaq kernel: protections[]: 0 0 0
> Sep 14 20:16:21 dhcpaq kernel: DMA: 1*4kB 1*8kB 0*16kB 1*32kB 0*64kB
0*128kB
> 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 44kB
> Sep 14 20:16:21 dhcpaq kernel: Normal: 20*4kB 3*8kB 1*16kB 0*32kB
0*64kB
> 0*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 376kB
> Sep 14 20:16:21 dhcpaq kernel: HighMem: empty
> Sep 14 20:16:21 dhcpaq kernel: nr_free_swap_pages: 96406
> Sep 14 20:16:21 dhcpaq kernel: Swap cache: add 49668, delete 42859,
find
> 20428/23905, race 0+1
> Sep 14 20:16:21 dhcpaq kernel: Out of Memory: Killed process 1147
(bk).
> 
> Barry Silverman		Voice:  416-368-7677 x234
> Disus Inc.			Cell:   416-407-8091
> 47 Colborne #303		Fax:    416-368-4933
> Toronto, Ontario
> M5E 1P8, Canada		email:  barry@disus.com
> PGP Key:
http://pgpkeys.mit.edu:11371/pks/lookup?op=get&search=0x4F5C9736
> 
> 
> -----Original Message-----
> From: Marcelo Tosatti [mailto:marcelo.tosatti@cyclades.com]
> Sent: Tuesday, September 14, 2004 3:12 PM
> To: Barry Silverman
> Subject: Re: OOM Killer problem since linux 2.6.8.1
> 
> 
> 
> Barry,
> 
> Can you please reproduce the OOM with the attached patch applied.
> 
> It will show us how many swap pages are available when tasks are
killed.
> 
> Thanks
> 
> On Mon, Sep 13, 2004 at 11:41:52PM -0400, Barry Silverman wrote:
> > Thank you,
> > I found the necessary patch files, and applied them.
> >
> > I have tried running the rc1-mm5 kernel - and I continue to get the
OOMs
> > when I do the following memory hungry command (for the linux
2.6.9-rc2
> > repository):
> >
> > "bk sccscat -h ChangeSet | bk check -acv -".
> >
> > The bk consistency check seems to grow to a very large virtual size
>
> > 170M, and I only have 120m physical memory. The swap space grew to
about
> > 96m out of a total 400m (I was using "top" to monitor)
> >
> > Is there any kind of diagnostic patch that you want me to apply? The
bug
> > happens every time I execute the command.
> >
> > Below is the log entry for the OOM:
> > Sep 13 23:46:36 dhcpaq kernel: oom-killer: gfp_mask=0x1d2
> > Sep 13 23:46:36 dhcpaq kernel: DMA per-cpu:
> > Sep 13 23:46:36 dhcpaq kernel: cpu 0 hot: low 2, high 6, batch 1
> > Sep 13 23:46:36 dhcpaq kernel: cpu 0 cold: low 0, high 2, batch 1
> > Sep 13 23:46:36 dhcpaq kernel: Normal per-cpu:
> > Sep 13 23:46:36 dhcpaq kernel: cpu 0 hot: low 12, high 36, batch 6
> > Sep 13 23:46:36 dhcpaq kernel: cpu 0 cold: low 0, high 12, batch 6
> > Sep 13 23:46:36 dhcpaq kernel: HighMem per-cpu: empty
> > Sep 13 23:46:36 dhcpaq kernel:
> > Sep 13 23:46:36 dhcpaq kernel: Free pages:         348kB (0kB
HighMem)
> > Sep 13 23:46:36 dhcpaq kernel: Active:26152 inactive:1691 dirty:0
> > writeback:0 unstable:0 free:87 slab:1092 mapped:27846 pagetables:183
> > Sep 13 23:46:36 dhcpaq kernel: DMA free:44kB min:44kB low:88kB
> > high:132kB active:11308kB inactive:988kB present:16384kB
> > Sep 13 23:46:36 dhcpaq kernel: protections[]: 0 0 0
> > Sep 13 23:46:38 dhcpaq kernel: Normal free:304kB min:300kB low:600kB
> > high:900kB active:93300kB inactive:5776kB present:106496kB
> > Sep 13 23:46:38 dhcpaq kernel: protections[]: 0 0 0
> > Sep 13 23:46:38 dhcpaq kernel: HighMem free:0kB min:128kB low:256kB
> > high:384kB active:0kB inactive:0kB present:0kB
> > Sep 13 23:46:38 dhcpaq kernel: protections[]: 0 0 0
> > Sep 13 23:46:38 dhcpaq kernel: DMA: 1*4kB 1*8kB 0*16kB 1*32kB 0*64kB
> > 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 44kB
> > Sep 13 23:46:38 dhcpaq kernel: Normal: 6*4kB 1*8kB 1*16kB 0*32kB
0*64kB
> > 2*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 304kB
> > Sep 13 23:46:38 dhcpaq kernel: HighMem: empty
> > Sep 13 23:46:38 dhcpaq kernel: Swap cache: add 185777, delete
179057,
> > find 63414/76283, race 0+0
> > Sep 13 23:46:38 dhcpaq kernel: Out of Memory: Killed process 1311
(bk).
> >
> > -----Original Message-----
> > From: Marcelo Tosatti [mailto:marcelo.tosatti@cyclades.com]
> > Sent: Monday, September 13, 2004 3:46 PM
> > To: Barry Silverman
> > Subject: Re: OOM Killer problem since linux 2.6.8.1
> >
> > On Mon, Sep 13, 2004 at 04:32:54PM -0400, Barry Silverman wrote:
> > > Which kernel is this patchset supposed to be applied against?
2.6.8.1
> > or
> > > 2.6.9-rc1? or can I get a full kernel with the patches applied
already
> > from
> > > somewhere directly?
> >
> > It applies on top of 2.6.9-rc1. I dont know where to find a tarball
of
> > its
> > full source.

----- End forwarded message -----
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
