content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: Porting to from Solaris 64bit to Linux 32B - 36B.
Date: Wed, 20 Nov 2002 10:36:14 -0700
Message-ID: <C5BF7C2C6ADF24448763CC46235FB3A691C833@ulysses.neocore.com>
From: "Jon Goldberg" <jgoldberg@neocore.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew,

	Will that return a 64 bit offset pointer to the file or just let me map 3-4GB in a 10 BG file with a 64 bit offset pointer.  What I would like to do is mmap the full 10GB file and walk it with a 64 bit pointer knowing that not more that 2GB can be in memory.

Thanks for all the help!

Jon

-----Original Message-----
From: Andrew Morton [mailto:akpm@digeo.com]
Sent: Wednesday, November 20, 2002 1:34 AM
To: Rik van Riel
Cc: Jon Goldberg; linux-mm@kvack.org
Subject: Re: Porting to from Solaris 64bit to Linux 32B - 36B.


Rik van Riel wrote:
> 
> On Tue, 19 Nov 2002, Jon Goldberg wrote:
> 
> >       We are currently at porting to Linux 2.4 kernel and I am having
> > troubles finding information on VM.  Since the 2.4 Kernel support large
> > amount of swap < 1TB and Physical Ram < 64GB.  Is there a way to get
> > memory functions like mmap to use a 64 bit pointer instead of the 32bit
> > pointer.  Since a memory mapped file the file is used as swap I should
> > be able to have it map a file larger than 4GB and have the OS do the
> > page management.
> 
> No, this is not possible because of fundamental reasons.
> 

I think he's asking "where is mmap64()"?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
