Date: Mon, 2 Oct 2006 08:57:07 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Get rid of zone_table V2
In-Reply-To: <20060930130811.2a7c0009.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0610020855400.12258@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609181215120.20191@schroedinger.engr.sgi.com>
 <20060924030643.e57f700c.akpm@osdl.org> <20060927021934.9461b867.akpm@osdl.org>
 <451A6034.20305@shadowen.org> <Pine.LNX.4.64.0609301135430.4012@schroedinger.engr.sgi.com>
 <20060930130811.2a7c0009.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Sat, 30 Sep 2006, Andrew Morton wrote:

> What patch is this patch patching?  get-rid-of-zone_table.patch or one of
> the ZONE_DMA-optionality ones?

It addresses breakage in optional ZONE DMA introduced by Andy Whitcrofts 
fix to get-rid-of-zone_table.patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
