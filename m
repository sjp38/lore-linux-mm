Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7FB776B01EE
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 14:22:22 -0400 (EDT)
Date: Thu, 1 Apr 2010 20:22:17 +0200
From: Heinz Diehl <htd@fancy-poultry.org>
Subject: Re: 2.6.34-rc3, BUG at mm/slab.c:2989
Message-ID: <20100401182217.GA23177@fancy-poultry.org>
Reply-To: linux-kernel@vger.kernel.org
References: <20100401175225.GA6581@fancy-poultry.org>
 <alpine.DEB.2.00.1004011257470.17168@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1004011257470.17168@router.home>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 01.04.2010, Christoph Lameter wrote: 

> Switch to SLUB and set SLUB_DEBUG_ON. Reboot and reproduce situation.
> Check the syslog after while. SLUB will repair the situation and continue
> if possible. There may not be failure.

Ok, will do immediately and try to reproduce. Thanks!

Heinz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
