Message-ID: <48908BD4.10408@linux-foundation.org>
Date: Wed, 30 Jul 2008 10:42:12 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: MMU notifiers review and some proposals
References: <20080724143949.GB12897@wotan.suse.de> <20080725214552.GB21150@duo.random> <20080726030810.GA18896@wotan.suse.de> <20080726113813.GD21150@duo.random> <20080726122826.GA17958@wotan.suse.de> <20080726130202.GA9598@duo.random> <20080726131450.GC21820@wotan.suse.de> <48907880.3020105@linux-foundation.org> <20080730145436.GJ11494@duo.random>
In-Reply-To: <20080730145436.GJ11494@duo.random>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:

> I think the current implementation is fine for the long run, it can
> provide the fastest performance when armed, and each invalidate either
> requires IPIs or it may may need to access the southbridge, so when
> freeing large areas of memory it's good being able to do a single
> invalidate.

Right. A couple of months ago we had this discussion and agreed that the begin / end was the way to go. I still support that decision.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
