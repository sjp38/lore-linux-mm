Subject: Re: [PATCH] generalized spin_lock_bit
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <20020720.152703.102669295.davem@redhat.com>
References: <1027196511.1555.767.camel@sinai>
	<20020720.152703.102669295.davem@redhat.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 21 Jul 2002 01:26:25 +0100
Message-Id: <1027211185.17234.48.camel@irongate.swansea.linux.org.uk>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: rml@tech9.net, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@conectiva.com.br, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Sat, 2002-07-20 at 23:27, David S. Miller wrote:
> Why not just use the existing bitops implementation?  The code is
> going to be mostly identical, ala:
> 
> 	while (test_and_set_bit(ptr, nr)) {
> 		while (test_bit(ptr, nr))
> 			barrier();
> 	}

Firstly your code is wrong for Intel already

Secondly many platforms want to implement their locks in other ways.
Atomic bitops are an x86 luxury so your proposal simply generates
hideously inefficient code compared to arch specific sanity


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
