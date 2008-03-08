Date: Sat, 8 Mar 2008 14:03:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] [6/13] Core maskable allocator
Message-Id: <20080308140334.15987554.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080307090716.9D3E91B419C@basil.firstfloor.org>
References: <200803071007.493903088@firstfloor.org>
	<20080307090716.9D3E91B419C@basil.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri,  7 Mar 2008 10:07:16 +0100 (CET)
Andi Kleen <andi@firstfloor.org> wrote:

> +static int __init setup_maskzone(char *s)
> +{
> +	do {
> +		if (isdigit(*s)) {
> +			mask_zone_size = memparse(s, &s);
> +		} else if (!strncmp(s, "force", 5)) {
> +			force_mask = 1;
> +			s += 5;
> +		} else
> +			return -EINVAL;
> +		if (*s == ',')
> +			++s;
> +	} while (*s);
> +	return 0;
> +}
> +early_param("maskzone", setup_maskzone);

please confirm mask_zone_size is aligned to MAX_ORDER.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
