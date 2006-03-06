Date: Mon, 6 Mar 2006 08:19:52 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: numa_maps update
In-Reply-To: <20060304122618.7867267a.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0603060818480.23752@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603030846170.13932@schroedinger.engr.sgi.com>
 <20060304010708.31697f71.akpm@osdl.org> <200603040559.16666.ak@suse.de>
 <Pine.LNX.4.64.0603041206260.18435@schroedinger.engr.sgi.com>
 <20060304122618.7867267a.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: ak@suse.de, hugh@veritas.com, linux-mm@kvack.org, mtk-manpages@gmx.net
List-ID: <linux-mm.kvack.org>

On Sat, 4 Mar 2006, Andrew Morton wrote:

> What about the PageLocked() accounting?  Do you really think that's
> necessary?  Should we change it to (or add) PageWriteback() accounting?

I will add pagewriteback accounting. Pagelocked is useful to see an 
an ongoing migration but we can remove that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
