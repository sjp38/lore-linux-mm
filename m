Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 87EF36B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 07:37:47 -0500 (EST)
Date: Tue, 17 Nov 2009 07:36:22 -0500
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [BUG]2.6.27.y some contents lost after writing to mmaped file
Message-ID: <20091117123622.GI27677@think>
References: <2df346410911151938r1eb5c5e4q9930ac179d61ef01@mail.gmail.com>
 <20091117015655.GA8683@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091117015655.GA8683@suse.de>
Sender: owner-linux-mm@kvack.org
To: Greg KH <gregkh@suse.de>
Cc: JiSheng Zhang <jszhang3@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org, jack@suse.cz
List-ID: <linux-mm.kvack.org>

On Mon, Nov 16, 2009 at 05:56:55PM -0800, Greg KH wrote:
> On Mon, Nov 16, 2009 at 11:38:57AM +0800, JiSheng Zhang wrote:
> > Hi,
> > 
> > I triggered a failure in an fs test with fsx-linux from ltp. It seems that
> > fsx-linux failed at mmap->write sequence.
> > 
> > Tested kernel is 2.6.27.12 and 2.6.27.39
> 
> Does this work on any kernel you have tested?  Or is it a regression?
> 
> > Tested file system: ext3, tmpfs.
> > IMHO, it impacts all file systems.
> > 
> > Some fsx-linux log is:
> > 
> > READ BAD DATA: offset = 0x2771b, size = 0xa28e
> > OFFSET  GOOD    BAD     RANGE
> > 0x287e0 0x35c9  0x15a9     0x80
> > operation# (mod 256) for the bad datamay be 21
> > ...
> > 7828: 1257514978.306753 READ     0x23dba thru 0x25699 (0x18e0 bytes)
> > 7829: 1257514978.306899 MAPWRITE 0x27eeb thru 0x2a516 (0x262c bytes)
> >  ******WWWW
> > 7830: 1257514978.307504 READ     0x2771b thru 0x319a8 (0xa28e bytes)
> >  ***RRRR***
> > Correct content saved for comparison
> > ...
> 
> Are you sure that the LTP is correct?  It wouldn't be the first time it
> wasn't...

I'm afraid fsx usually finds bugs.  I thought Jan Kara recently fixed
something here in ext3, does 2.6.32-rc work?

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
