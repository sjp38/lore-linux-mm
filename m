Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0C0146B01EE
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 13:59:44 -0400 (EDT)
Date: Thu, 1 Apr 2010 12:59:38 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: 2.6.34-rc3, BUG at mm/slab.c:2989
In-Reply-To: <20100401175225.GA6581@fancy-poultry.org>
Message-ID: <alpine.DEB.2.00.1004011257470.17168@router.home>
References: <20100401175225.GA6581@fancy-poultry.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 1 Apr 2010, Heinz Diehl wrote:

> Apr  1 18:20:33 liesel kernel: kernel BUG at mm/slab.c:2989!

Typical for slab metadata corruption. You need to run with debugging on.

Switch to SLUB and set SLUB_DEBUG_ON. Reboot and reproduce situation.
Check the syslog after while. SLUB will repair the situation and continue
if possible. There may not be failure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
