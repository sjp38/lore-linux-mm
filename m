Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4DC866B004F
	for <linux-mm@kvack.org>; Mon,  1 Jun 2009 08:33:30 -0400 (EDT)
Date: Mon, 1 Jun 2009 22:33:42 +1000
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Use kzfree in crypto API context initialization and
	key/iv handling
Message-ID: <20090601123342.GA13261@gondor.apana.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090601085814.3e010533@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: davem@davemloft.net, riel@redhat.com, research@subreption.com, linux-kernel@vger.kernel.org, pageexec@freemail.hu, linux-mm@kvack.org, torvalds@osdl.org, linux-crypto@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
>
> Zeroing long term keys makes sense but for the short lifepsan keys used on
> the wire its a bit pointless irrespective of speed (I suspect done
> properly the performance impact would be close to nil anyway)

Sure, though we're not actually arguing whether keys should be
zeroed here, but the metadata, i.e., pointers to keys, buffers,
etc.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
