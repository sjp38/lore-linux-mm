Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j5N1gF7r018422
	for <linux-mm@kvack.org>; Wed, 22 Jun 2005 21:42:15 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j5N1gFjx185928
	for <linux-mm@kvack.org>; Wed, 22 Jun 2005 21:42:15 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j5N1gEa3020688
	for <linux-mm@kvack.org>; Wed, 22 Jun 2005 21:42:15 -0400
Subject: Re: [PATCH 2.6.12-rc5 4/10] mm: manual page migration-rc3
	--	add-sys_migrate_pages-rc3.patch
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <42BA11AF.4080302@engr.sgi.com>
References: <20050622163908.25515.49944.65860@tomahawk.engr.sgi.com>
	 <20050622163934.25515.22804.81297@tomahawk.engr.sgi.com>
	 <1119461013.18457.61.camel@localhost>  <42BA11AF.4080302@engr.sgi.com>
Content-Type: text/plain
Date: Wed, 22 Jun 2005 18:42:02 -0700
Message-Id: <1119490922.18457.73.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@engr.sgi.com>
Cc: Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andi Kleen <ak@suse.de>, Christoph Hellwig <hch@infradead.org>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>, Paul Jackson <pj@sgi.com>, Nathan Scott <nathans@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-06-22 at 20:34 -0500, Ray Bryant wrote:
> Dave Hansen wrote:
> > On Wed, 2005-06-22 at 09:39 -0700, Ray Bryant wrote:
> > 
> >>+asmlinkage long
> >>+sys_migrate_pages(pid_t pid, __u32 count, __u32 *old_nodes, __u32 *new_nodes)
> >>+{
> >  
> > Should the buffers be marked __user?
> > 
> 
> I've tried it both ways, but with the __user in the system call declaration,
> you still need to have it on the copy_from_user() calls to get sparse to
> shut up, so it really doesn't appear to help much to put it in the 
> declaration.  I'm easy though.  If you think it helps, I'll add it.

Looking at fs/read_write.c, the convention seems to be to put them in
the function declaration.  That's all that I was looking at.  No big
deal.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
