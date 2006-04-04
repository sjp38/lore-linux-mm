Date: Tue, 4 Apr 2006 08:21:33 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/3] mm: speculative get_page
In-Reply-To: <20060219020159.9923.94877.sendpatchset@linux.site>
Message-ID: <Pine.LNX.4.64.0604040820540.26807@schroedinger.engr.sgi.com>
References: <20060219020140.9923.43378.sendpatchset@linux.site>
 <20060219020159.9923.94877.sendpatchset@linux.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 4 Apr 2006, Nick Piggin wrote:

> +	/*
> +	 * PageNoNewRefs is set in order to prevent new references to the
> +	 * page (eg. before it gets removed from pagecache). Wait until it
> +	 * becomes clear (and checks below will ensure we still have the
> +	 * correct one).
> +	 */
> +	while (unlikely(PageNoNewRefs(page)))
> +		cpu_relax();

That part looks suspiciously like we need some sort of lock here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
