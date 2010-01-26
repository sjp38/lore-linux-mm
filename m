Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id AF7DB6B00A8
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 16:35:43 -0500 (EST)
Date: Tue, 26 Jan 2010 15:35:33 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: BUG at mm/slab.c:2990 with 2.6.33-rc5-tuxonice
In-Reply-To: <4B5F5794.8020302@cs.helsinki.fi>
Message-ID: <alpine.DEB.2.00.1001261534380.30784@router.home>
References: <74fd948d1001261121r7e6d03a4i75ce40705abed4e0@mail.gmail.com>  <4B5F52FE.5000201@crca.org.au> <1264539045.3536.1348.camel@calx> <4B5F5794.8020302@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Matt Mackall <mpm@selenic.com>, Nigel Cunningham <ncunningham@crca.org.au>, Pedro Ribeiro <pedrib@gmail.com>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org >> linux-mm" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 26 Jan 2010, Pekka Enberg wrote:

> Looks like slab corruption to me which is usually not a slab bug but caused by
> buggy callers. Is CONFIG_DEBUG_SLAB enabled?

Typical BUG for slab metadata that has been overwritten by
something.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
