Date: Tue, 6 Jan 2004 21:30:36 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: shutdown panic in mm_release (really flush_tlb_others?)
Message-Id: <20040106213036.5051129b.akpm@osdl.org>
In-Reply-To: <4500000.1073444277@[10.10.2.4]>
References: <4500000.1073444277@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" <mbligh@aracnet.com> wrote:
>
> And the award for longest panic I've ever seen goes to ....
>  <drumroll> ....
> 
>  (there were several of these in sequence).
>  Looks like it was trying to printk an error on shutdown ...
>  really maybe " [<c0115242>] flush_tlb_others+0x22/0xd0"
> 
>  Probably the same panic I sent out the other day in a slight
>  disguise ... "BUG_ON(!cpus_equal(cpumask, tmp));" in flush_tlb_others

Cute.  Didn't you have a patch for this?  Or a proposed solution which
you've been too lazy to type in?  ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
