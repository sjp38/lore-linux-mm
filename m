Date: Tue, 6 Dec 2005 19:35:24 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC 1/3] Framework for accurate node based statistics
Message-ID: <20051206183524.GU11190@wotan.suse.de>
References: <20051206182843.19188.82045.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051206182843.19188.82045.sendpatchset@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

> +static inline void mod_node_page_state(int node, enum node_stat_item item, int delta)
> +{
> +	vm_stat_diff[get_cpu()][node][item] += delta;
> +	put_cpu();

Instead of get/put_cpu I would use a local_t. This would give much better code
on i386/x86-64.  I have some plans to port over all the MM statistics counters
over to local_t, still stuck, but for new code it should be definitely done.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
