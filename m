Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0F45C6B00A0
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 12:14:02 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 2A19982C514
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 12:17:57 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id mOy23rjM+U-E for <linux-mm@kvack.org>;
	Tue, 17 Feb 2009 12:17:57 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B8A2782C519
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 12:17:49 -0500 (EST)
Date: Tue, 17 Feb 2009 12:06:37 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] Export symbol ksize()
In-Reply-To: <84144f020902170903g5756cf4cy57f98cd5955ff2e3@mail.gmail.com>
Message-ID: <alpine.DEB.1.10.0902171205390.15929@qirst.com>
References: <1234272104-10211-1-git-send-email-kirill@shutemov.name>  <20090212104349.GA13859@gondor.apana.org.au>  <1234435521.28812.165.camel@penberg-laptop>  <20090212105034.GC13859@gondor.apana.org.au>  <1234454104.28812.175.camel@penberg-laptop>
 <20090215133638.5ef517ac.akpm@linux-foundation.org>  <1234734194.5669.176.camel@calx>  <20090215135555.688ae1a3.akpm@linux-foundation.org>  <1234741781.5669.204.camel@calx>  <alpine.DEB.1.10.0902171115010.29986@qirst.com>
 <84144f020902170903g5756cf4cy57f98cd5955ff2e3@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Herbert Xu <herbert@gondor.apana.org.au>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-crypto@vger.kernel.org, Geert.Uytterhoeven@sonycom.com
List-ID: <linux-mm.kvack.org>

On Tue, 17 Feb 2009, Pekka Enberg wrote:

> Hmm, kmem_cache_size() seems bit pointless to me. For
> kmem_cache_create()'d caches, actual allocated size should be more or
> less optimal with no extra space.

Cacheline alignment and word alignment etc etc can still add some space to
the object.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
