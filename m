Received: by ug-out-1314.google.com with SMTP id c2so812470ugf
        for <linux-mm@kvack.org>; Fri, 06 Jul 2007 10:18:41 -0700 (PDT)
Date: Fri, 6 Jul 2007 21:18:37 +0400
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] mm: fixup /proc/vmstat output
Message-ID: <20070706171837.GA5763@martell.zuzino.mipt.ru>
References: <1183721734.7054.102.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1183721734.7054.102.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <wfg@mail.ustc.edu.cn>, Rusty Russell <rusty@rustcorp.com.au>, Christoph Lameter <clameter@sgi.com>, riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 06, 2007 at 01:35:34PM +0200, Peter Zijlstra wrote:
> Line up the vmstat_text with zone_stat_item
> 
> enum zone_stat_item {
> 	/* First 128 byte cacheline (assuming 64 bit words) */
> 	NR_FREE_PAGES,
> 	NR_INACTIVE,
> 	NR_ACTIVE,
> 
> We current have nr_active and nr_inactive reversed.

OK with patch, though using initializers canbe handy to prevent such
things in future:

	static const char * const vmstat_text[] = {
		[NR_FREE_PAGES] = "nr_free_pages",
		...

> --- linux-2.6.orig/mm/vmstat.c
> +++ linux-2.6/mm/vmstat.c
> @@ -700,8 +700,8 @@ const struct seq_operations pagetypeinfo
>  static const char * const vmstat_text[] = {
>  	/* Zoned VM counters */
>  	"nr_free_pages",
> -	"nr_active",
>  	"nr_inactive",
> +	"nr_active",
>  	"nr_anon_pages",
>  	"nr_mapped",
>  	"nr_file_pages",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
