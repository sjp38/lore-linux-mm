Date: Mon, 17 Jun 2002 16:25:33 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: linux page table
Message-ID: <20020617232533.GB25360@holomorphy.com>
References: <1024325907014473@caramail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1024325907014473@caramail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: anya aitali <tiziri00@caramail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2002 at 04:58:27PM +0000, anya aitali wrote:
> Can you oriented me. I had a PFN (page frame number) for 
> one page and I want assign it to a entry for a pte_page.
> What are the LINUX kernel functions should I use.
> Thanks. 

In 2.5 this is done with pfn_pte(), in 2.4 mk_pte().


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
