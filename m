Date: Wed, 07 Sep 2005 07:28:44 -0700
From: "Martin J. Bligh" <mbligh@mbligh.org>
Reply-To: "Martin J. Bligh" <mbligh@mbligh.org>
Subject: Re: Hugh's alternate page fault scalability approach on 512p Altix
Message-ID: <20660000.1126103324@[10.10.2.4]>
In-Reply-To: <Pine.LNX.4.62.0509061129380.16939@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0509061129380.16939@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>, torvalds@osdl.org
Cc: akpm@osdl.org, nickpiggin@yahoo.com.au, hugh@veritas.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Anticipatory prefaulting raises the highest fault rate obtainable three-fold
> through gang scheduling faults but may allocate some pages to a task that are
> not needed.

IIRC that costed more than it saved, at least for forky workloads like a
kernel compile - extra cost in zap_pte_range etc. If things have changed
substantially in that path, I guess we could run the numbers again - has
been a couple of years.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
