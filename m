Date: Fri, 16 Nov 2001 06:52:43 -0800 (PST)
Message-Id: <20011116.065243.134136673.davem@redhat.com>
Subject: Re: parisc scatterlist doesn't want page/offset
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <200111160730.AAA18774@puffin.external.hp.com>
References: <200111160730.AAA18774@puffin.external.hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: grundler@puffin.external.hp.com
Cc: linux-mm@kvack.org, parisc-linux@lists.parisc-linux.org
List-ID: <linux-mm.kvack.org>

No, you must have page+offset because in the future the
"address" field of scatterlist is going to disappear
and _ONLY_ page+offset will be used.

Do not hack around it, just fix your scatterlist definition instead.
I'm trying to push a Documentation/DMA-mapping.txt update to Linus
which talks about this explicitly and requires your port to have those
fields. 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
