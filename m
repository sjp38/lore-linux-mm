From: David Howells <dhowells@redhat.com>
In-Reply-To: <1201112977.5443.29.camel@localhost.localdomain>
References: <1201112977.5443.29.camel@localhost.localdomain>
Subject: Re: [PATCH] Fix procfs task exe symlink
Date: Wed, 23 Jan 2008 20:46:31 +0000
Message-ID: <22275.1201121191@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Helsley <matthltc@us.ibm.com>
Cc: dhowells@redhat.com, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Al Viro <viro@ftp.linux.org.uk>, William H Taber <wtaber@us.ibm.com>, William Cesar de Oliveira <owilliam@br.ibm.com>, Richard Kissel <rkissel@us.ibm.com>, Christoph Hellwig <hch@lst.de>
List-ID: <linux-mm.kvack.org>

Matt Helsley <matthltc@us.ibm.com> wrote:

> To solve the problem this patch changes the way that the kernel resolves a
> task's exe symlink. Instead of walking the VMAs to find the first
> executable file-backed VMA we store a reference to the exec'd file in the
> mm_struct -- /foo/bar/jvm/bin/java in the example above.

Sounds interesting.

> 	nommu-only code paths are untested -- lacking access to nommu system

I could test it, but it'll have to wait until I get back from LCA in a couple
of weeks time.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
