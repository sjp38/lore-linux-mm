Date: Thu, 8 Feb 2007 13:55:22 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Drop PageReclaim()
In-Reply-To: <Pine.LNX.4.64.0702081340380.13255@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0702081351270.14036@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702070612010.14171@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0702071428590.30412@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0702081319530.12048@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0702081331290.12167@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0702081340380.13255@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Oh gosh. I hope I finally got my head around this. The page is taken off 
the LRU for writeback then PageReclaim is set and its put back to the 
inactive list when writeback ends. This is different from regular file 
writeback where we leave the page on the LRU.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
