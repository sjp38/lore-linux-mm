Subject: Re: 2.5.33-mm3 dbench hang and 2.5.33 page allocation failures
From: Steven Cole <elenstev@mesatop.com>
In-Reply-To: <3D779C77.39ABD952@zip.com.au>
References: <1031246639.2799.68.camel@spc9.esa.lanl.gov>
	<3D779C77.39ABD952@zip.com.au>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 05 Sep 2002 12:22:36 -0600
Message-Id: <1031250156.2799.86.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2002-09-05 at 12:03, Andrew Morton wrote:
> Steven Cole wrote:
> > 
> > I booted 2.5.33-mm3 and ran dbench with increasing
> > numbers of clients: 1,2,3,4,6,8,10,12,16,etc. while
> > running vmstat -n 1 600 from another terminal.
> > 
> > After about 3 minutes, the output from vmstat stopped,
> > and the dbench 16 output stopped.  The machine would
> > respond to pings, but not to anything else. I had to
> > hard-reset the box. Nothing interesting was saved in
> > /var/log/messages. I have the output from vmstat if needed.
> 
> That sounds like a race-leading-to-deadlock.  Feeding the SYSRQ-T
> output into ksymoops is about the only way you have of diagnosing that
> I'm afraid.

I have CONFIG_MAGIC_SYSRQ=y for 2.5.33-mm3, so I'll reboot and try to
get some useful information.

> 
> > The test box is dual p3, 1GB, scsi, ext3 fs.
> > Kernels are SMP,_HIGHMEM4G, no PREEMPT, no HIGHPTE.
> > 
> > Earlier this morning, I ran 2.5.33 and the dbench test and got many
> > page allocation failure messages before I terminated the test.
> > 
> > Steven
> > 
> > Sep  5 07:20:01 spc5 kernel: dbench: page allocation failure. order:0, mode:0x50
> > Sep  5 07:28:32 spc5 kernel: dbench: page allocation failure. order:0, mode:0x50
> 
> Presumably, this was when running a lot more than 16 clients?

Yep, about 52 clients when those messages started coming in hot and
heavy, but they started with fewer clients.  I can rerun the test if
that threshold is of interest.

> 
> It's just a warning, btw.  Allocation failures are expected for GFP_NOIO
> allocations.  Increasingly so lately, actually.

Ok, thanks.  But the total hang is something else. I'll try alt-sysrq-t
with 2.5.33-mm3 and see what can be determined.

Steven

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
