Date: Thu, 12 Jun 2003 14:00:14 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [PATCH] Fix vmtruncate race and distributed filesystem race
Message-Id: <20030612140014.32b7244d.akpm@digeo.com>
In-Reply-To: <20030612134946.450e0f77.akpm@digeo.com>
References: <133430000.1055448961@baldur.austin.ibm.com>
	<20030612134946.450e0f77.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: dmccr@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@digeo.com> wrote:
>
> do_no_page()
> {
> 	int sequence = 0;
> 	...
> 
> retry:
> 	new_page = vma->vm_ops->nopage(vma, address & PAGE_MASK, &sequence);
> 	....
> 	if (vma->vm_ops->revalidate && vma->vm_opa->revalidate(vma, sequence))
> 		goto retry;
> }

And this does require that ->nopage be entered with page_table_lock held,
and that it drop it.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
