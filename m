Date: Tue, 16 Jan 2007 11:04:05 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 5/29] Start calling simple PTI functions
In-Reply-To: <20070113024606.29682.18276.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Message-ID: <Pine.LNX.4.64.0701161103140.6637@schroedinger.engr.sgi.com>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
 <20070113024606.29682.18276.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Davies <pauld@gelato.unsw.edu.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 13 Jan 2007, Paul Davies wrote:

> @@ -308,6 +309,7 @@
>  } while (0)
>  
>  struct mm_struct {
> +	pt_t page_table;					/* Page table */
>  	struct vm_area_struct * mmap;		/* list of VMAs */

Why are you changing the location of the page table pointer in mm struct?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
