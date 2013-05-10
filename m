Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 1C0316B0034
	for <linux-mm@kvack.org>; Fri, 10 May 2013 05:20:47 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <518C5B5E.4010706@gmail.com>
References: <1368093011-4867-1-git-send-email-wenchaolinux@gmail.com>
 <20130509141329.GC11497@suse.de>
 <518C5B5E.4010706@gmail.com>
Subject: Re: [RFC PATCH V1 0/6] mm: add a new option MREMAP_DUP to mmrep
 syscall
Content-Transfer-Encoding: 7bit
Message-Id: <20130510092255.592E1E0085@blue.fi.intel.com>
Date: Fri, 10 May 2013 12:22:55 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wenchao <wenchaolinux@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, walken@google.com, viro@zeniv.linux.org.uk, kirill.shutemov@linux.intel.com, xiaoguangrong@linux.vnet.ibm.com, anthony@codemonkey.ws, stefanha@gmail.com, xemul@parallels.com

wenchao wrote:
> ao? 2013-5-9 22:13, Mel Gorman a??e??:
> > On Thu, May 09, 2013 at 05:50:05PM +0800, wenchaolinux@gmail.com wrote:
> >> From: Wenchao Xia <wenchaolinux@gmail.com>
> >>
> >>    This serial try to enable mremap syscall to cow some private memory region,
> >> just like what fork() did. As a result, user space application would got a
> >> mirror of those region, and it can be used as a snapshot for further processing.
> >>
> >
> > What not just fork()? Even if the application was threaded it should be
> > managable to handle fork just for processing the private memory region
> > in question. I'm having trouble figuring out what sort of application
> > would require an interface like this.
> >
>    It have some troubles: parent - child communication, sometimes
> page copy.
>    I'd like to snapshot qemu guest's RAM, currently solution is:
> 1) fork()
> 2) pipe guest RAM data from child to parent.
> 3) parent write down the contents.

CC Pavel

I wounder if you can reuse the CRIU approach for memory snapshoting.

http://thread.gmane.org/gmane.linux.kernel/1483158/

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
