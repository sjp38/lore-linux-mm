Date: Mon, 16 Aug 1999 23:29:27 -0700
Message-Id: <199908170629.XAA23911@pizda.davem.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <199908162328.QAA24338@google.engr.sgi.com>
	(kanoj@google.engr.sgi.com)
Subject: Re: [bigmem-patch] 4GB with Linux on IA32
References: <199908162328.QAA24338@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kanoj@google.engr.sgi.com
Cc: andrea@suse.de, alan@lxorguk.ukuu.org.uk, torvalds@transmeta.com, sct@redhat.com, Gerhard.Wichert@pdb.siemens.de, Winfried.Gerhard@pdb.siemens.de, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

   For example, on a 2.2.10 kernel:
   [kanoj@entity kern]$ gid __va | grep drivers
   drivers/char/mem.c:124: if (copy_to_user(buf, __va(p), count))
   drivers/char/mem.c:142: return do_write_mem(file, __va(p), p, buf, count, ppos);

Ok, this one could be a problem.

   drivers/scsi/sym53c8xx.c:572:#define remap_pci_mem(base, size)  ((u_long) __va(base))

Sparc specific ifdef'd code, it doesn't matter for ix86.

   drivers/video/creatorfb.c
 ...
   drivers/sbus/char/zs.c

More Sparc specific drivers.

So in essence there are only two spots in mem.c which you might need
to worry about on ix86.

Later,
David S. Miller
davem@redhat.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
