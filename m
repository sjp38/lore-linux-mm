Date: Wed, 16 Aug 2006 10:08:20 +0200
From: Andreas Mohr <andi@rhlx01.fht-esslingen.de>
Subject: Re: [PATCH 2/2] Simple shared page tables
Message-ID: <20060816080820.GA6330@rhlx01.fht-esslingen.de>
References: <20060815225607.17433.32727.sendpatch@wildcat> <20060815225618.17433.84777.sendpatch@wildcat>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060815225618.17433.84777.sendpatch@wildcat>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Arjan van de Ven <arjan@infradead.org>, Diego Calleja <diegocg@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Aug 15, 2006 at 05:56:18PM -0500, Dave McCracken wrote:
> +config PTSHARE
> +	bool "Share page tables"
> +	default y
> +	help
> +	  Turn on sharing of page tables between processes for large shared
> +	  memory regions.

A bit too terse IMHO. It could have mentioned (briefly!) that it is able
to save up to several MB of memory, or any other benefits.
Plus, are there drawbacks? (Management overhead, ...)

Andreas Mohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
