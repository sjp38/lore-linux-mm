Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 789D76B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 08:35:05 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 19so1377260fgg.4
        for <linux-mm@kvack.org>; Tue, 10 Feb 2009 05:35:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1234272104-10211-1-git-send-email-kirill@shutemov.name>
References: <1234272104-10211-1-git-send-email-kirill@shutemov.name>
Date: Tue, 10 Feb 2009 15:35:03 +0200
Message-ID: <84144f020902100535i4d626a9fj8cbb305120cf332a@mail.gmail.com>
Subject: Re: [PATCH] Export symbol ksize()
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-crypto@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 10, 2009 at 3:21 PM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> It needed for crypto.ko
>
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>

That's bit terse for a changelog. I did a quick grep but wasn't able
to find the offending call-site. Where is it?

We unexported ksize() because it's a problematic interface and you
almost certainly want to use the alternatives (e.g. krealloc). I think
I need bit more convincing to apply this patch...

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
