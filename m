Received: from hermes.rz.uni-sb.de (hermes.rz.uni-sb.de [134.96.7.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA10402
	for <linux-mm@kvack.org>; Sat, 20 Mar 1999 10:33:41 -0500
Message-ID: <36F3BFDA.ED1B42B7@stud.uni-sb.de>
Date: Sat, 20 Mar 1999 16:33:46 +0100
From: Manfred Spraul <masp0008@stud.uni-sb.de>
Reply-To: masp0008@stud.uni-sb.de
MIME-Version: 1.0
Subject: Re: Possible optimization in ext2_file_write()
References: <199903181816.XAA12650@vxindia.vxindia.veritas.com> <199903191448.OAA01416@dax.scot.redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: V Ganesh <ganesh@vxindia.veritas.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" wrote:
> 
> Hi,
> 
> On Thu, 18 Mar 1999 23:46:57 +0530 (IST), V Ganesh
> <ganesh@vxindia.veritas.com> said:
> 
> >       it looks like whenever we write a partial block which
> > doesn't exist in the buffer cache, ext2_file_write() (and
> > possibly the write functions of other filesystems) directly
> > reads that block from the block device without checking if
> > it is present in the page cache.
> 
> Correct...

I don't know what you are exactly talking about, but there is another
problem except speed:
Most modern harddisks remap bad sectors, so sometimes you can't read a
sector, but if you write the sector is remapped.

I.e. if you "create a new file, write 400 bytes, close the file, sync",
then the data sector should not be read.

Our current Windows 95 & Windows NT file system drivers read the data
sector, and that has caused problems (older ZIP disks, SyQuest,
my own damnaged harddisk?-I don't remember the details).

Regards,
	Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
