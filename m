Date: Thu, 18 May 2000 12:59:21 +0200
From: Jan Niehusmann <jan@gondor.com>
Subject: Re: PATCH: Possible solution to VM problems (take 2)
Message-ID: <20000518125921.A1570@gondor.com>
References: <Pine.LNX.4.21.0005140101390.4107-100000@loke.as.arizona.edu> <Pine.LNX.4.21.0005180221450.7333-100000@loke.as.arizona.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0005180221450.7333-100000@loke.as.arizona.edu>; from ckulesa@loke.as.arizona.edu on Thu, May 18, 2000 at 03:17:25AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Craig Kulesa <ckulesa@loke.as.arizona.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 18, 2000 at 03:17:25AM -0700, Craig Kulesa wrote:
> A stubborn problem that remains is the behavior when lots of
> dirty pages pile up quickly.  Doing a giant 'dd' from /dev/zero to a
> file on disk still causes gaps of unresponsiveness.  Here's a short vmstat
> session on a 128 MB PIII system performing a 'dd if=/dev/zero of=dummy.dat
> bs=1024k count=256':

While 'dd if=/dev/zero of=file' can, of course, generate dirty pages at
an insane rate, I see the same unresponsiveness when doing cp -a from 
one filesystem to another. (and even from a slow harddisk to a faster one).

Shouldn't the writing of dirty pages occur at least at the same rate 
as reading data from the slower hard disk? 

(My system: linux-2.3.99pre9-2, wait_buffers_02.patch, 
truncate_inode_pages_01.patch, lvm, PII/333Mhz, 256MB, ide & scsi hard disks)


Jan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
