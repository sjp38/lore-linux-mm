Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id ED2006B004D
	for <linux-mm@kvack.org>; Thu, 19 Nov 2009 09:43:34 -0500 (EST)
Date: Thu, 19 Nov 2009 15:43:31 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [BUG]2.6.27.y some contents lost after writing to mmaped file
Message-ID: <20091119144331.GC24836@duck.suse.cz>
References: <2df346410911151938r1eb5c5e4q9930ac179d61ef01@mail.gmail.com>
 <20091117015655.GA8683@suse.de>
 <20091117123622.GI27677@think>
 <20091117190635.GB31105@duck.suse.cz>
 <20091118221756.367c005e@ustc>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091118221756.367c005e@ustc>
Sender: owner-linux-mm@kvack.org
To: JiSheng Zhang <jszhang3@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Greg KH <gregkh@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org, rmk@arm.linux.org.uk, linux-arm@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Wed 18-11-09 22:17:56, JiSheng Zhang wrote:
> On Tue, 17 Nov 2009 20:06:35 +0100
> Jan Kara <jack@suse.cz> wrote:
> 
> > On Tue 17-11-09 07:36:22, Chris Mason wrote:
> > > On Mon, Nov 16, 2009 at 05:56:55PM -0800, Greg KH wrote:
> > > > On Mon, Nov 16, 2009 at 11:38:57AM +0800, JiSheng Zhang wrote:
> > > > > Hi,
> > > > > 
> > > > > I triggered a failure in an fs test with fsx-linux from ltp. It seems that
> > > > > fsx-linux failed at mmap->write sequence.
> > > > > 
> > > > > Tested kernel is 2.6.27.12 and 2.6.27.39
> > > > 
> > > > Does this work on any kernel you have tested?  Or is it a regression?
> > > > 
> > > > > Tested file system: ext3, tmpfs.
> > > > > IMHO, it impacts all file systems.
> > > > > 
> > > > > Some fsx-linux log is:
> > > > > 
> > > > > READ BAD DATA: offset = 0x2771b, size = 0xa28e
> > > > > OFFSET  GOOD    BAD     RANGE
> > > > > 0x287e0 0x35c9  0x15a9     0x80
> > > > > operation# (mod 256) for the bad datamay be 21
> > > > > ...
> > > > > 7828: 1257514978.306753 READ     0x23dba thru 0x25699 (0x18e0 bytes)
> > > > > 7829: 1257514978.306899 MAPWRITE 0x27eeb thru 0x2a516 (0x262c bytes)
> > > > >  ******WWWW
> > > > > 7830: 1257514978.307504 READ     0x2771b thru 0x319a8 (0xa28e bytes)
> > > > >  ***RRRR***
> > > > > Correct content saved for comparison
> > > > > ...
> >   Hmm, how long does it take to reproduce? I'm running fsx-linux on tmpfs
> > for a while on 2.6.27.21 and didn't hit the problem yet.
> 
> I forget to mention that the test were done on an arm board with 64M ram. 
> I have tested fsx-linux again on pc, it seems that failure go away.
>
> > > > Are you sure that the LTP is correct?  It wouldn't be the first time it
> > > > wasn't...
> > > 
> > > I'm afraid fsx usually finds bugs.  I thought Jan Kara recently fixed
> > > something here in ext3, does 2.6.32-rc work?
> >   Yeah, fsx usually finds bugs. Note that he sees the problem also on tmpfs
> > so it's not ext3 problem. Anyway, trying to reproduce with 2.6.32-rc? would
> > be interesting.
> 
> Currently the arm board doesn't support 2.6.32-rc. But I test with 2.6.32-rc7
> On my pc box, there's no failure so far.
  OK, so it's either ARM specific or it's triggered by low amount of
available memory (you might want to try testing your PC with mem=64M).

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
