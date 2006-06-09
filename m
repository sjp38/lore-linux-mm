From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 01/14] Per zone counter functionality
Date: Fri, 9 Jun 2006 06:28:57 +0200
References: <20060608230239.25121.83503.sendpatchset@schroedinger.engr.sgi.com> <20060608230244.25121.76440.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060608230244.25121.76440.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200606090628.57497.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, akpm@osdl.org, Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

> +/*
> + * For an unknown interrupt state
> + */
> +void mod_zone_page_state(struct zone *zone, enum zone_stat_item item,
> +				int delta)
> +{
> +	unsigned long flags;
> +
> +	local_irq_save(flags);
> +	__mod_zone_page_state(zone, item, delta);
> +	local_irq_restore(flags);

It would be nicer to use some variant of local_t - then you could do that
without turning off interrupts (which some CPUs like P4 don't like)

There currently is not 1 byte local_t but it could be added.

Mind you it would only make sense when most of the calls are not already
with interrupts disabled.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
