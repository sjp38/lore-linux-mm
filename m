Received: from sap-ag.de (imon [194.39.131.5])
  by smtpde02.sap-ag.de (out) with ESMTP id JAA18529
  for <linux-mm@kvack.org>; Fri, 3 Dec 1999 09:12:37 +0100 (MEZ)
Received: from ls3010.wdf.sap-ag.de (ls3010.wdf.sap-ag.de [10.18.104.24])
	by sap-ag.de (8.8.8/8.8.8) with ESMTP id JAA29635
	for <linux-mm@kvack.org>; Fri, 3 Dec 1999 09:14:15 +0100 (MET)
Received: (from d020782@localhost)
	by ls3010.wdf.sap-ag.de (8.9.3/8.9.3) id JAA10529
	for linux-mm@kvack.org; Fri, 3 Dec 1999 09:14:15 +0100
Resent-Message-Id: <199912030814.JAA10529@ls3010.wdf.sap-ag.de>
Resent-To: linux-mm@kvack.org
Subject: Re: [RFC] mapping parts of shared memory
References: <199912022052.VAA24022@jaures.ilog.fr> <Pine.GSO.4.10.9912021615230.19875-100000@weyl.math.psu.edu>
From: Christoph Rohland <hans-christoph.rohland@sap.com>
Date: 03 Dec 1999 09:10:12 +0100
In-Reply-To: viro@math.psu.edu's message of "2 Dec 1999 22:47:04 +0100"
Message-ID: <qwwg0xko36j.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>, haible@ilog.fr
Cc: Linux Kernel Mailing List <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

viro@math.psu.edu (Alexander Viro) writes:

> On Thu, 2 Dec 1999, Bruno Haible wrote:
> 
> > 5) Use the proc filesystem. Implement a file /proc/ipc/shm/42 as being
> >    equivalent to the shared memory segment with id 42.
> >    File type: regular file
> >    File size: the shm segment's size
> >    File contents (for use by read, write, mmap): the shm segment's data
> >    File owner/group: the shm segment's owner and group
> >    truncate(): return -EINVAL
> > 
> > Not only would this solve your "mmap of shared memory" problem, it would
> > become possible to view and edit shared memory using "cat", "hexdump" and
> > "vi". Benefits of the "everything is a file" philosophy.
> 
> Don't do it in procfs. Make a separate filesystem and mount it on the
> empty directory in /proc, if you really need it (I'ld rather use some
> other location - even /dev/shm would be better). This filesystem will have
> _nothing_ with proc in terms of code. There is enough mess in procfs
> already. Keep this one separate.

I totally agree. After looking at the shm code I concluded that making
a filesystem out of it will cleanup the code a lot. There is much
duplication of code from the mm layer.

I am just working on this filesystem.

Greetings
          Christoph

-- 
Christoph Rohland
SAP AG           
LinuxLab                        Email: hans-christoph.rohland@sap.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
