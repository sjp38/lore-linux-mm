Message-ID: <42847A80.6020002@engr.sgi.com>
Date: Fri, 13 May 2005 04:59:28 -0500
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] Re: [PATCH 2.6.12-rc3 4/8] mm: manual page migration-rc2
 -- add-sys_migrate_pages-rc2.patch
References: <4282115C.40207@engr.sgi.com>	<20050512.154148.52902091.taka@valinux.co.jp>	<42838742.3030903@engr.sgi.com> <20050513.085034.74732081.taka@valinux.co.jp>
In-Reply-To: <20050513.085034.74732081.taka@valinux.co.jp>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: raybry@sgi.com, marcelo.tosatti@cyclades.com, ak@suse.de, haveblue@us.ibm.com, hch@infradead.org, linux-mm@kvack.org, nathans@sgi.com, raybry@austin.rr.com, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Hirokazu Takahashi wrote:
> Hi Ray,
> 
> 

>>
>>Well, what could be done would be the following, I suppose:
>>
>>If follow_page() returns NULL and the vma maps a file, we could
>>lookup the page in the radix tree, and if we find it, and if it
>>is on a node that we are migrating from, we could add the page
>>to the set of pages to be migrated.
>>
>>The disadvantage of this is that we could do a LOT of radix
>>tree lookups and find relatively few pages.  (Our approach of
> 
> 
> 
> How about find_get_pages() for whole mmap()'ed ranges?
> With it, you may not need to call follow_page().
> 

No, you need to call follow_page() to get, for example, the
read-write pages of a shared library that are process private.

For the moment, I would propose punting on this issue.  I don't
think there will be many pages in this category, and if they do
show up later, we have a couple of approaches to deal with them.

-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
