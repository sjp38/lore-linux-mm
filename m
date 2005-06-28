Date: Tue, 28 Jun 2005 15:17:05 -0700 (PDT)
From: Christoph Lameter <christoph@lameter.com>
Subject: Re: [patch 2] mm: speculative get_page
In-Reply-To: <200506281432.30868.jbarnes@virtuousgeek.org>
Message-ID: <Pine.LNX.4.62.0506281514580.6284@graphe.net>
References: <42C0AAF8.5090700@yahoo.com.au> <42C0D717.2080100@yahoo.com.au>
 <20050627.220827.21920197.davem@davemloft.net> <200506281432.30868.jbarnes@virtuousgeek.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Cc: "David S. Miller" <davem@davemloft.net>, nickpiggin@yahoo.com.au, wli@holomorphy.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 Jun 2005, Jesse Barnes wrote:

> On ia64 at least, the unlock is only a one way barrier.  The store to 
> realease the lock uses release semantics (since the lock is declared 
> volatile), which implies that prior stores are visible before the 
> unlock occurs, but subsequent accesses can 'float up' above the unlock.  
> See http://www.gelato.unsw.edu.au/linux-ia64/0304/5122.html for some 
> more details.

The manual talks about "accesses" not stores. So this applies to loads and 
stores. Subsequent accesses can float up but only accesses prior to the 
instruction with release semantics (like an unlock) are guaranteed to be 
visible.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
