Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DBA3D6B0095
	for <linux-mm@kvack.org>; Mon,  1 Jun 2009 00:48:08 -0400 (EDT)
Date: Mon, 1 Jun 2009 14:48:37 +1000
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Use kzfree in crypto API context initialization and
	key/iv handling
Message-ID: <20090601044837.GA9220@gondor.apana.org.au>
References: <20090531025720.GC9033@oblivion.subreption.com> <20090530.230213.73434433.davem@davemloft.net> <4A22967C.3080304@redhat.com> <20090531.214623.76344831.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090531.214623.76344831.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
To: David Miller <davem@davemloft.net>
Cc: riel@redhat.com, research@subreption.com, linux-kernel@vger.kernel.org, pageexec@freemail.hu, linux-mm@kvack.org, torvalds@osdl.org, alan@lxorguk.ukuu.org.uk, linux-crypto@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, May 31, 2009 at 09:46:23PM -0700, David Miller wrote:
> 
> I don't even want to think about what this does to IPSEC rule creation
> rates, that that matters heavily for cell phone networks where
> hundreds of thousands of nodes come in and out of the server and each
> such entry requires creating 4 IPSEC rules.

I completely agree.  The zeroing of metadata is gratuitous.

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
