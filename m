Date: Fri, 17 Aug 2007 14:02:01 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 3/6] Embed zone_id information within the zonelist->zones
 pointer
In-Reply-To: <20070817201748.14792.37660.sendpatchset@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0708171400570.9635@schroedinger.engr.sgi.com>
References: <20070817201647.14792.2690.sendpatchset@skynet.skynet.ie>
 <20070817201748.14792.37660.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Lee.Schermerhorn@hp.com, ak@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 17 Aug 2007, Mel Gorman wrote:

> +/*
> + * SMP will align zones to a large boundary so the zone ID will fit in the
> + * least significant biuts. Otherwise, ZONES_SHIFT must be 2 or less to
> + * fit

ZONES_SHIFT is always 2 or less....

Acked-by: Christoph Lameter <clameter@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
