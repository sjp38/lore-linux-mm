Date: Wed, 23 Jan 2008 20:41:28 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] Fix procfs task exe symlink
Message-ID: <20080123194128.GA2571@lst.de>
References: <1201112977.5443.29.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1201112977.5443.29.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Helsley <matthltc@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Al Viro <viro@ftp.linux.org.uk>, David Howells <dhowells@redhat.com>, William H Taber <wtaber@us.ibm.com>, William Cesar de Oliveira <owilliam@br.ibm.com>, Richard Kissel <rkissel@us.ibm.com>, Christoph Hellwig <hch@lst.de>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 23, 2008 at 10:29:37AM -0800, Matt Helsley wrote:
> For executables on the stackable MVFS filesystem the current procfs methods for
> implementing a task's exe symlink do not point to the correct file and
> applications relying on the symlink fail (see the java example below).

Dou you have a pointer to the source code for that filesystem?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
