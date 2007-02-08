Date: Thu, 8 Feb 2007 14:40:52 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Drop PageReclaim()
In-Reply-To: <20070208143746.79c000f5.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0702081438510.15063@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702070612010.14171@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0702071428590.30412@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0702081319530.12048@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0702081331290.12167@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0702081340380.13255@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0702081351270.14036@schroedinger.engr.sgi.com>
 <20070208140338.971b3f53.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0702081411030.14424@schroedinger.engr.sgi.com>
 <20070208142431.eb81ae70.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0702081425000.14424@schroedinger.engr.sgi.com>
 <20070208143746.79c000f5.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 8 Feb 2007, Andrew Morton wrote:

> > Those sleeping on the page must have their own process context
> > to do so.
> 
> You've lost me.  I don't see what that sort of thing has to do with
> end_page_writeback() and rotate_reclaimable_page().

One could replace the PageReclaim bit with a process waiting on the 
writeback bit to clear. The process would then do the rotation. But that 
would require too many processes.

Hmmm... Does not look as if I can get that bit freed up. It was always a 
mystery to me what the thing did. At least I know now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
