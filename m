Subject: Re: [PATCH] generalized spin_lock_bit
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <20020720.183133.67807986.davem@redhat.com>
References: <1027196511.1555.767.camel@sinai>
	<20020720.152703.102669295.davem@redhat.com>
	<1027211185.17234.48.camel@irongate.swansea.linux.org.uk>
	<20020720.183133.67807986.davem@redhat.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 21 Jul 2002 14:48:54 +0100
Message-Id: <1027259334.16819.98.camel@irongate.swansea.linux.org.uk>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: rml@tech9.net, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@conectiva.com.br, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Sun, 2002-07-21 at 02:31, David S. Miller wrote:
> For an asm-generic/bitlock.h implementation it is more than
> fine.  That way we get asm-i386/bitlock.h that does whatever
> it wants to do and the rest of asm-*/bitlock.h includes
> the generic version until the arch maintainer sees fit to
> do otherwise.

For an asm-generic one yes. Although you do need to add a cpu_relax() in
the inner loop

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
