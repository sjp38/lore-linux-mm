Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 468716B004F
	for <linux-mm@kvack.org>; Mon,  1 Jun 2009 03:56:46 -0400 (EDT)
Date: Mon, 1 Jun 2009 08:58:14 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] Use kzfree in crypto API context initialization and
 key/iv handling
Message-ID: <20090601085814.3e010533@lxorguk.ukuu.org.uk>
In-Reply-To: <20090601044837.GA9220@gondor.apana.org.au>
References: <20090531025720.GC9033@oblivion.subreption.com>
	<20090530.230213.73434433.davem@davemloft.net>
	<4A22967C.3080304@redhat.com>
	<20090531.214623.76344831.davem@davemloft.net>
	<20090601044837.GA9220@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: David Miller <davem@davemloft.net>, riel@redhat.com, research@subreption.com, linux-kernel@vger.kernel.org, pageexec@freemail.hu, linux-mm@kvack.org, torvalds@osdl.org, linux-crypto@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Jun 2009 14:48:37 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Sun, May 31, 2009 at 09:46:23PM -0700, David Miller wrote:
> > 
> > I don't even want to think about what this does to IPSEC rule creation
> > rates, that that matters heavily for cell phone networks where
> > hundreds of thousands of nodes come in and out of the server and each
> > such entry requires creating 4 IPSEC rules.
> 
> I completely agree.  The zeroing of metadata is gratuitous.

Zeroing long term keys makes sense but for the short lifepsan keys used on
the wire its a bit pointless irrespective of speed (I suspect done
properly the performance impact would be close to nil anyway)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
