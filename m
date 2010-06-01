Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A98FE6B01D7
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 09:47:30 -0400 (EDT)
Date: Tue, 1 Jun 2010 08:44:11 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [BUG] slub crashes on dma allocations
In-Reply-To: <4C023854.3090002@cs.helsinki.fi>
Message-ID: <alpine.DEB.2.00.1006010844020.6979@router.home>
References: <20100526153757.GB2232@osiris.boeblingen.de.ibm.com> <alpine.DEB.2.00.1005270916220.5762@router.home> <20100527190440.GA2205@osiris.boeblingen.de.ibm.com> <4C023854.3090002@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 30 May 2010, Pekka Enberg wrote:

> > Yes, that fixes the bug. Thanks!
>
> We need this for .33 and .34 stable, right?

Right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
