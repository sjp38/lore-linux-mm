Subject: Re: [PATCH] generalized spin_lock_bit
From: Robert Love <rml@tech9.net>
In-Reply-To: <20020720.152703.102669295.davem@redhat.com>
References: <1027196511.1555.767.camel@sinai>
	<20020720.152703.102669295.davem@redhat.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 20 Jul 2002 15:46:14 -0700
Message-Id: <1027205175.1116.830.camel@sinai>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: torvalds@transmeta.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@conectiva.com.br, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Sat, 2002-07-20 at 15:27, David S. Miller wrote:
>    From: Robert Love <rml@tech9.net>
>    Date: 20 Jul 2002 13:21:51 -0700
>    
>    Thanks to Christoph Hellwig for prodding to make it per-architecture,
>    Ben LaHaise for the loop optimization, and William Irwin for the
>    original bit locking.
> 
> Just note that the implementation of these bit spinlocks will be
> extremely expensive on some platforms that lack "compare and swap"
> type instructions (or something similar like "load locked, store
> conditional" as per mips/alpha).

That is what they do use, but the code is pushed into the architecture
headers so you can do something else if you choose.

I originally just had a single generic version, but people representing
the greater good of SPARC and PA-RISC argued otherwise.  It should be
simple enough to just paste the generic implementations into your
asm/spinlock.h if you do not want to do any hand-tuning.

	Robert Love

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
