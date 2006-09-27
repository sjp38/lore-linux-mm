Date: Wed, 27 Sep 2006 09:19:00 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] zone table removal miss merge
In-Reply-To: <20060927112315.GA8093@shadowen.org>
Message-ID: <Pine.LNX.4.64.0609270911060.9171@schroedinger.engr.sgi.com>
References: <20060927021934.9461b867.akpm@osdl.org> <20060927112315.GA8093@shadowen.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 27 Sep 2006, Andy Whitcroft wrote:

> The below should fix it.

Acked-by: Christoph Lameter <clameter@sgi.com>


Note that if ZONE_DMA is off then ZONES_WIDTH may become
0 and therefore also ZONES_PGSHIFT is zero.

If you then do

#define ZONEID_PGSHIFT ZONES_PGSHIFT

then ZONEID_PGSHIFT will be 0!

So this could be an issue for the optional ZONE_DMA patch.

Could you also make sure that ZONEID_PGSHIFT is set correctly even if 
ZONES_WIDTH is zero?

This affects the optional ZONE_DMA patch. zone table removal should be 
fine with just the above patch.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
