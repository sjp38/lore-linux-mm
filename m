Subject: Re: 2.5.33-mm4 filemap_copy_from_user: Unexpected page fault
From: Steven Cole <elenstev@mesatop.com>
In-Reply-To: <3D78E79B.78B202DE@zip.com.au>
References: <3D78DD07.E36AE3A9@zip.com.au>
	<1031331803.2799.178.camel@spc9.esa.lanl.gov>
	<3D78E79B.78B202DE@zip.com.au>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 06 Sep 2002 11:54:07 -0600
Message-Id: <1031334847.2799.206.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2002-09-06 at 11:36, Andrew Morton wrote:
> Steven Cole wrote:
> > 
> > ...
> > > Does this fix?
> > ...
> > Unfortunately no.
> 
> Well, isn't this fun?  umm.  You're _sure_ you ran the right kernel
> and such?

Oops, forgot to include linux-mm on the earlier reply.
Yes I am sure I ran the right kernel.

> 
> Could you send your /proc/mounts, and tell me which of those partitions
> you're running the test on?
> 
Here that is again, for the linux-mm list:

[steven@spc5 linux-2.5.33-mm4]$ cat /proc/mounts
rootfs / rootfs rw 0 0
/dev/root / ext3 rw 0 0
/proc /proc proc rw 0 0
none /dev/pts devpts rw 0 0
/dev/sda5 /home ext3 rw 0 0
none /dev/shm tmpfs rw 0 0
/dev/sdb2 /share ext2 rw 0 0
/dev/sda3 /usr ext3 rw 0 0


Test were run on /home (ext3) with single exception of one earlier test
on /share (ext2).

Steven

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
