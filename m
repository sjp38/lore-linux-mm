Date: Mon, 24 Sep 2007 12:05:56 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch -mm 4/5] mm: test and set zone reclaim lock before starting
 reclaim
In-Reply-To: <alpine.DEB.0.9999.0709212312560.13727@chino.kir.corp.google.com>
Message-ID: <Pine.LNX.4.64.0709241202280.29673@schroedinger.engr.sgi.com>
References: <alpine.DEB.0.9999.0709212311130.13727@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709212312160.13727@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709212312400.13727@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709212312560.13727@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 22 Sep 2007, David Rientjes wrote:

> +++ b/include/linux/mmzone.h
> @@ -320,6 +320,10 @@ static inline void zone_set_flag(struct zone *zone, zone_flags_t flag)
>  {
>  	set_bit(flag, &zone->flags);
>  }
> +static inline int zone_test_and_set_flag(struct zone *zone, zone_flags_t flag)
> +{
> +	return test_and_set_bit(flag, &zone->flags);
> +}

Missing blank line.

>  static inline void zone_clear_flag(struct zone *zone, zone_flags_t flag)
>  {
>  	clear_bit(flag, &zone->flags);
> diff --git a/mm/vmscan.c b/mm/vmscan.c

The rest looks fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
