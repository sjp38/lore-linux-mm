Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: [PATCH] slabasap-mm5_A2
Date: Mon, 9 Sep 2002 17:33:44 -0400
References: <200209071006.18869.tomlins@cam.org> <200209081142.02839.tomlins@cam.org> <3D7BB97A.6B6E4CA5@digeo.com>
In-Reply-To: <3D7BB97A.6B6E4CA5@digeo.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200209091733.44112.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Andrew,

Found three oops when checking this afternoon's log.  Looks like *total_scanned can
be zero...

how about;

ratio = pages > *total_scanned ? pages / (*total_scanned | 1) : 1;

Ed

> +	 * NOTE: for now I do this for all zones.  If we find this is too
> +	 * aggressive on large boxes we may want to exculude ZONE_HIGHMEM
> +	 */
> +	ratio = (pages / *total_scanned) + 1;
> +	shrink_dcache_memory(ratio, gfp_mask);
> +	shrink_icache_memory(ratio, gfp_mask);




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
