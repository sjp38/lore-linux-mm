Date: Thu, 24 Jan 2008 19:09:28 -0500
Message-Id: <200801250009.m0P09SBe010417@agora.fsl.cs.sunysb.edu>
From: Erez Zadok <ezk@cs.sunysb.edu>
Subject: Re: [PATCH] Fix procfs task exe symlink 
In-reply-to: Your message of "Wed, 23 Jan 2008 20:01:05 +0100."
             <Pine.LNX.4.64.0801231945530.12676@fbirervta.pbzchgretzou.qr>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Engelhardt <jengelh@computergmbh.de>
Cc: Matt Helsley <matthltc@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Al Viro <viro@ftp.linux.org.uk>, David Howells <dhowells@redhat.com>, William H Taber <wtaber@us.ibm.com>, William Cesar de Oliveira <owilliam@br.ibm.com>, Richard Kissel <rkissel@us.ibm.com>, Christoph Hellwig <hch@lst.de>
List-ID: <linux-mm.kvack.org>

In message <Pine.LNX.4.64.0801231945530.12676@fbirervta.pbzchgretzou.qr>, Jan Engelhardt writes:
> 
> On Jan 23 2008 10:29, Matt Helsley wrote:
> >
> >For executables on the stackable MVFS filesystem the current procfs
> >methods for implementing a task's exe symlink do not point to the
> >correct file and applications relying on the symlink fail (see the
> >java example below).
> 
> This reminds me of unoionfs - it also had this issue, but IIRC,
> it eventually got solved. (Should now display /union/exe rather
> than /lowerlevel/exe.) Unionfs developers should know more.

Unionfs resolved this by fully implementing the address_space ops, as well
as ->mmap (i.e., one cannot "cheat" and inherit the lower address_space).

Erez.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
