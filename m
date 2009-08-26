Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 17CB66B0062
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 05:52:29 -0400 (EDT)
Date: Wed, 26 Aug 2009 11:51:18 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [Bug #14016] mm/ipw2200 regression
Message-ID: <20090826095118.GA26280@cmpxchg.org>
References: <riPp5fx5ECC.A.2IG.qsGlKB@chimera> <_yaHeGjHEzG.A.FIH.7sGlKB@chimera> <84144f020908252309u5cff8afdh2214577ca4db9b5d@mail.gmail.com> <20090826082741.GA25955@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090826082741.GA25955@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Mel Gorman <mel@skynet.ie>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 26, 2009 at 10:27:41AM +0200, Johannes Weiner wrote:

> 64 pages, presumably 256k, for fw->boot_size while current ipw
> firmware images have ~188k.  I don't know jack squat about this
> driver, but given the field name and the struct:
> 
> 	struct ipw_fw {
> 		__le32 ver;
> 		__le32 boot_size;
> 		__le32 ucode_size;
> 		__le32 fw_size;
> 		u8 data[0];
> 	};
> 
> fw->boot_size alone being that big sounds a bit fishy to me.

Scrap that, I just noticed the second call to ipw_load_firmware() a
few lines later... :)

	Hannes 'when logic and proportion have fallen sloppy dead...'

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
