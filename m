Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B64C26B00AC
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 11:32:23 -0500 (EST)
Subject: Re: [PATCH] Export symbol ksize()
From: Joe Perches <joe@perches.com>
In-Reply-To: <20090216135643.GA6927@cmpxchg.org>
References: <1234272104-10211-1-git-send-email-kirill@shutemov.name>
	 <84144f020902100535i4d626a9fj8cbb305120cf332a@mail.gmail.com>
	 <20090210134651.GA5115@epbyminw8406h.minsk.epam.com>
	 <Pine.LNX.4.64.0902101605070.20991@melkki.cs.Helsinki.FI>
	 <20090216135643.GA6927@cmpxchg.org>
Content-Type: text/plain
Date: Mon, 16 Feb 2009 08:32:32 -0800
Message-Id: <1234801952.20430.33.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Pekka J Enberg <penberg@cs.helsinki.fi>, "Kirill A. Shutemov" <kirill@shutemov.name>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-crypto@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, Geert.Uytterhoeven@sonycom.com
List-ID: <linux-mm.kvack.org>

On Mon, 2009-02-16 at 14:56 +0100, Johannes Weiner wrote:
> One problem is that zeroing ksize()
> bytes can have an overhead of nearly twice the actual allocation size.

A possible good thing is when linux has a
mechanism to use known zeroed memory in
kzalloc or kcalloc, it's already good to go.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
