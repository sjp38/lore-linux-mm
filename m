Date: Thu, 12 May 2005 15:41:48 +0900 (JST)
Message-Id: <20050512.154148.52902091.taka@valinux.co.jp>
Subject: Re: [PATCH 2.6.12-rc3 4/8] mm: manual page migration-rc2 --
 add-sys_migrate_pages-rc2.patch
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <4282115C.40207@engr.sgi.com>
References: <20050511043821.10876.47127.71762@jackhammer.engr.sgi.com>
	<20050511.222314.10910241.taka@valinux.co.jp>
	<4282115C.40207@engr.sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: raybry@engr.sgi.com
Cc: raybry@sgi.com, marcelo.tosatti@cyclades.com, ak@suse.de, haveblue@us.ibm.com, hch@infradead.org, linux-mm@kvack.org, nathans@sgi.com, raybry@austin.rr.com, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Hi,

> > BTW, I'm not sure whether it's enough that migrate_vma() can only
> > migrate currently mapped pages. This may leave some pages in the
> > page-cache if they're not mapped to the process address spaces yet.
> > 
> > Thanks,
> > Hirokazu Takahashi.
> 
> If the page isn't mapped, there is no good way to match it up with
> a particular process id, is there?   :-)

I just thought of the page, belonging to some file which is
mmap()ed to the target process to be migrated. The page may
not be accessed and the associated PTE isn't set yet.
if vma->vm_file->f_mapping equals page_mapping(page), the page
should be migrated. 

Pages in the swap-cache have the same problem since the related
PTEs may be clean.

But these cases may be rare and your approach seems to be good
enough in most cases.

> We've handled that separately in the actual migration application,
> by sync'ing the system and  then freeing clean page cache pages
> before the migrate_pages() system call is invoked.
> 
> -- 
> Best Regards,
> Ray

Thanks,
Hirokazu Takahashi.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
