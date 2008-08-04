Message-ID: <4897780A.20100@linux-foundation.org>
Date: Mon, 04 Aug 2008 16:43:38 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH] SLUB: dynamic per-cache MIN_PARTIAL
References: <Pine.LNX.4.64.0808050037400.26319@sbz-30.cs.Helsinki.FI>
In-Reply-To: <Pine.LNX.4.64.0808050037400.26319@sbz-30.cs.Helsinki.FI>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, matthew@wil.cx, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Well looks okay. Sigh. I sure wish we would deal with the page allocator
performance instead of adding more buffering.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
