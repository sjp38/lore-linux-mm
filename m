Date: Wed, 02 Apr 2003 17:42:25 -0600
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: [PATCH 2.5.66-mm2] Fix page_convert_anon locking issues
Message-ID: <110950000.1049326945@baldur.austin.ibm.com>
In-Reply-To: <20030402153845.0770ef54.akpm@digeo.com>
References: <8910000.1049303582@baldur.austin.ibm.com>
 <20030402132939.647c74a6.akpm@digeo.com>
 <80300000.1049320593@baldur.austin.ibm.com>
 <20030402150903.21765844.akpm@digeo.com>
 <102170000.1049325787@baldur.austin.ibm.com>
 <20030402153845.0770ef54.akpm@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--On Wednesday, April 02, 2003 15:38:45 -0800 Andrew Morton
<akpm@digeo.com> wrote:

> But:
> 
> +	/* Double check to make sure the pte page hasn't been freed */
> +	if (!pmd_present(*pmd))
> +		goto out_unmap;
> +
> 	==> munmap, pte page is freed, reallocated for pagecache, someone
> 	    happens to write the correct value into it.
> 	
> +	if (page_to_pfn(page) != pte_pfn(*pte))
> +		goto out_unmap;
> +
> +	if (addr)
> +		*addr = address;
> +

Oops.  The pmd_present() check should be after the page_to_pfn() !=
pte_pfn() check.

Dave

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
