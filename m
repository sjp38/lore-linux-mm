Message-ID: <428B9269.2080907@engr.sgi.com>
Date: Wed, 18 May 2005 14:07:21 -0500
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2.6.12-rc3 4/8] mm: manual page migration-rc2 -- add-sys_migrate_pages-rc2.patch
References: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com> <20050511043821.10876.47127.71762@jackhammer.engr.sgi.com> <20050511082457.GA24134@infradead.org>
In-Reply-To: <20050511082457.GA24134@infradead.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Christoph Hellwig wrote:

> 
>>+	if (nr_busy > 0) {
>>+		pass++;
>>+		if (pass > 10)
>>+			return -EAGAIN;
>>+		/* wait until some I/O completes and try again */
>>+		blk_congestion_wait(WRITE, HZ/10);
>>+		goto retry;
> 
> 
> this is a layering violation.  How to wait is up to the implementor
> of the address_space
> 

Christoph,

I've done the other changes you suggested, but am a little confused
by this one.  Is your suggestion that I should be calling:

vma->vm_file->f_mapping->a_ops->writepages()

(assuming this exists)

instead of doing the blk_congestion_wait()?  There is no "wait"
function defined in the aops vector as near as I can tell.

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
