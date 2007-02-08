Date: Thu, 8 Feb 2007 14:26:48 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Drop PageReclaim()
In-Reply-To: <20070208142431.eb81ae70.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0702081425000.14424@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702070612010.14171@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0702071428590.30412@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0702081319530.12048@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0702081331290.12167@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0702081340380.13255@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0702081351270.14036@schroedinger.engr.sgi.com>
 <20070208140338.971b3f53.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0702081411030.14424@schroedinger.engr.sgi.com>
 <20070208142431.eb81ae70.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 8 Feb 2007, Andrew Morton wrote:

> > We have a mechanism to trigger events based on the end of writeback 
> > (also triggered in end_page_writeback).
> 
> Not sure what you're referring to there.

      smp_mb__after_clear_bit();
      wake_up_page(page, PG_writeback);

> > But I guess we are not using it 
> > because we do not have a process context?
> 
> end_page_writeback() usually runs in hard IRQ context.

Those sleeping on the page must have their own process context
to do so.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
