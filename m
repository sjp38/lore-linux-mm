Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2B1406B0037
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 14:08:02 -0500 (EST)
Received: by mail-qc0-f169.google.com with SMTP id w7so11434524qcr.0
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 11:08:01 -0800 (PST)
Received: from qmta13.emeryville.ca.mail.comcast.net (qmta13.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:243])
        by mx.google.com with ESMTP id w9si10676896qgw.173.2014.02.10.11.08.00
        for <linux-mm@kvack.org>;
        Mon, 10 Feb 2014 11:08:01 -0800 (PST)
Date: Mon, 10 Feb 2014 13:07:58 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Memory allocator semantics
In-Reply-To: <52F60699.8010204@iki.fi>
Message-ID: <alpine.DEB.2.10.1402101304110.17517@nuc>
References: <20140102203320.GA27615@linux.vnet.ibm.com> <52F60699.8010204@iki.fi>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@iki.fi>
Cc: paulmck@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, penberg@kernel.org, mpm@selenic.com

On Sat, 8 Feb 2014, Pekka Enberg wrote:

> So to be completely honest, I don't understand what is the race in (A) that
> concerns the *memory allocator*.  I also don't what the memory allocator can
> do in (B) and (C) which look like double-free and use-after-free,
> respectively, to me. :-)

Well it seems to be some academic mind game to me.

Does an invocation of the allocator have barrier semantics or not?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
