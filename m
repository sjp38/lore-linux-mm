Date: Fri, 30 Jan 2004 11:47:01 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.2-rc2-mm2
Message-Id: <20040130114701.18aec4e8.akpm@osdl.org>
In-Reply-To: <1075490624.4272.7.camel@laptop.fenrus.com>
References: <20040130014108.09c964fd.akpm@osdl.org>
	<1075489136.5995.30.camel@moria.arnor.net>
	<200401302007.26333.thomas.schlichter@web.de>
	<1075490624.4272.7.camel@laptop.fenrus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: arjanv@redhat.com
Cc: thomas.schlichter@web.de, thoffman@arnor.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tim Hockin <thockin@sun.com>
List-ID: <linux-mm.kvack.org>

Arjan van de Ven <arjanv@redhat.com> wrote:
>
> 
> directly calling sys_ANYTHING sounds really wrong to me...
> 

It's a philosophical thing.  Is a kernel thread like a user process which
happens to be running from the kernel or it is a piece of mainline kernel
code which happens to have its own execution context?  I rather favour the
latter...

In this case it looks like it will just happen to work, because
nfsd_setuser() is executed by nfsd, and kernel threads are allowed to do
copy_from_user() with the source in kernel memory.  ick.

Tim, I do think it would be neater to add another entry point in sys.c for
nfsd and just do a memcpy.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
