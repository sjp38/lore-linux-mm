Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0FCCA6B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 14:06:38 -0500 (EST)
Date: Tue, 17 Nov 2009 20:06:35 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [BUG]2.6.27.y some contents lost after writing to mmaped file
Message-ID: <20091117190635.GB31105@duck.suse.cz>
References: <2df346410911151938r1eb5c5e4q9930ac179d61ef01@mail.gmail.com> <20091117015655.GA8683@suse.de> <20091117123622.GI27677@think>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091117123622.GI27677@think>
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: Greg KH <gregkh@suse.de>, JiSheng Zhang <jszhang3@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org, jack@suse.cz
List-ID: <linux-mm.kvack.org>

On Tue 17-11-09 07:36:22, Chris Mason wrote:
> On Mon, Nov 16, 2009 at 05:56:55PM -0800, Greg KH wrote:
> > On Mon, Nov 16, 2009 at 11:38:57AM +0800, JiSheng Zhang wrote:
> > > Hi,
> > > 
> > > I triggered a failure in an fs test with fsx-linux from ltp. It seems that
> > > fsx-linux failed at mmap->write sequence.
> > > 
> > > Tested kernel is 2.6.27.12 and 2.6.27.39
> > 
> > Does this work on any kernel you have tested?  Or is it a regression?
> > 
> > > Tested file system: ext3, tmpfs.
> > > IMHO, it impacts all file systems.
> > > 
> > > Some fsx-linux log is:
> > > 
> > > READ BAD DATA: offset = 0x2771b, size = 0xa28e
> > > OFFSET  GOOD    BAD     RANGE
> > > 0x287e0 0x35c9  0x15a9     0x80
> > > operation# (mod 256) for the bad datamay be 21
> > > ...
> > > 7828: 1257514978.306753 READ     0x23dba thru 0x25699 (0x18e0 bytes)
> > > 7829: 1257514978.306899 MAPWRITE 0x27eeb thru 0x2a516 (0x262c bytes)
> > >  ******WWWW
> > > 7830: 1257514978.307504 READ     0x2771b thru 0x319a8 (0xa28e bytes)
> > >  ***RRRR***
> > > Correct content saved for comparison
> > > ...
  Hmm, how long does it take to reproduce? I'm running fsx-linux on tmpfs
for a while on 2.6.27.21 and didn't hit the problem yet.

> > Are you sure that the LTP is correct?  It wouldn't be the first time it
> > wasn't...
> 
> I'm afraid fsx usually finds bugs.  I thought Jan Kara recently fixed
> something here in ext3, does 2.6.32-rc work?
  Yeah, fsx usually finds bugs. Note that he sees the problem also on tmpfs
so it's not ext3 problem. Anyway, trying to reproduce with 2.6.32-rc? would
be interesting.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
