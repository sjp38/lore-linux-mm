From: Blaisorblade <blaisorblade@yahoo.it>
Subject: Re: [patch 00/14] remap_file_pages protection support
Date: Wed, 3 May 2006 02:25:49 +0200
References: <20060430172953.409399000@zion.home.lan> <4456D5ED.2040202@yahoo.com.au>
In-Reply-To: <4456D5ED.2040202@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200605030225.54598.blaisorblade@yahoo.it>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>, Ulrich Drepper <drepper@redhat.com>, Val Henson <val.henson@intel.com>
List-ID: <linux-mm.kvack.org>

On Tuesday 02 May 2006 05:45, Nick Piggin wrote:
> blaisorblade@yahoo.it wrote:
> > This will be useful since the VMA lookup at fault time can be a
> > bottleneck for some programs (I've received a report about this from
> > Ulrich Drepper and I've been told that also Val Henson from Intel is
> > interested about this). I guess that since we use RB-trees, the slowness
> > is also due to the poor cache locality of RB-trees (since RB nodes are
> > within VMAs but aren't accessed together with their content), compared
> > for instance with radix trees where the lookup has high cache locality
> > (but they have however space usage problems, possibly bigger, on 64-bit
> > machines).

> Let's try get back to the good old days when people actually reported
> their bugs (togther will *real* numbers) to the mailing lists. That way,
> everybody gets to think about and discuss the problem.

I've not seen the numbers indeed, I've been told of a problem with a "customer 
program" and Ingo connected my work with this problem. Frankly, I've been 
always astonished about how looking up a 10-level tree can be slow. Poor 
cache locality is the only thing that I could think about.

That said, it was an add-on, not the original motivation of the work.
-- 
Inform me of my mistakes, so I can keep imitating Homer Simpson's "Doh!".
Paolo Giarrusso, aka Blaisorblade (Skype ID "PaoloGiarrusso", ICQ 215621894)
http://www.user-mode-linux.org/~blaisorblade
Chiacchiera con i tuoi amici in tempo reale! 
 http://it.yahoo.com/mail_it/foot/*http://it.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
