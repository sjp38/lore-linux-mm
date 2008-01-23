Date: Wed, 23 Jan 2008 20:01:05 +0100 (CET)
From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [PATCH] Fix procfs task exe symlink
In-Reply-To: <1201112977.5443.29.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0801231945530.12676@fbirervta.pbzchgretzou.qr>
References: <1201112977.5443.29.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Helsley <matthltc@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Al Viro <viro@ftp.linux.org.uk>, David Howells <dhowells@redhat.com>, William H Taber <wtaber@us.ibm.com>, William Cesar de Oliveira <owilliam@br.ibm.com>, Richard Kissel <rkissel@us.ibm.com>, Christoph Hellwig <hch@lst.de>
List-ID: <linux-mm.kvack.org>

On Jan 23 2008 10:29, Matt Helsley wrote:
>
>For executables on the stackable MVFS filesystem the current procfs
>methods for implementing a task's exe symlink do not point to the
>correct file and applications relying on the symlink fail (see the
>java example below).

This reminds me of unoionfs - it also had this issue, but IIRC,
it eventually got solved. (Should now display /union/exe rather
than /lowerlevel/exe.) Unionfs developers should know more.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
