Date: Wed, 25 Feb 2004 14:07:27 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] Distributed mmap API
Message-Id: <20040225140727.0cde826e.akpm@osdl.org>
In-Reply-To: <200402251604.19040.phillips@arcor.de>
References: <20040216190927.GA2969@us.ibm.com>
	<200402211400.16779.phillips@arcor.de>
	<20040222233911.GB1311@us.ibm.com>
	<200402251604.19040.phillips@arcor.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: paulmck@us.ibm.com, sct@redhat.com, hch@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Daniel Phillips <phillips@arcor.de> wrote:
>
> -			pte = ptep_get_and_clear(ptep);
> +			if (unlikely(!all) && is_anon(pfn_to_page(pfn)))
> +				continue;
> +			pte = ptep_get_and_clear(ptep); /* get dirty bit atomically */
>  			tlb_remove_tlb_entry(tlb, ptep, address+offset);
>  			if (pfn_valid(pfn)) {

I think you need to check pfn_valid() before running is_anon(pfn_to_page())
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
