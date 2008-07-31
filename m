Message-ID: <4891C9D5.8000500@linux-foundation.org>
Date: Thu, 31 Jul 2008 09:19:01 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: MMU notifiers review and some proposals
References: <20080724143949.GB12897@wotan.suse.de> <20080725214552.GB21150@duo.random> <20080726030810.GA18896@wotan.suse.de> <20080726113813.GD21150@duo.random> <20080726122826.GA17958@wotan.suse.de> <20080726130202.GA9598@duo.random> <20080726131450.GC21820@wotan.suse.de> <48907880.3020105@linux-foundation.org> <20080730145436.GJ11494@duo.random> <48908BD4.10408@linux-foundation.org> <20080731061419.GB32644@wotan.suse.de>
In-Reply-To: <20080731061419.GB32644@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:

> That's OK. We don't have to make decisions just by people supporting one
> way or the other, because I'll come up with some competing patches and
> if they turn out to be significantly simpler to the core VM without having
> a significant negative impact on performance then naturally everybody should
> be happy to merge them, so nobody has to argue with handwaving.

We make decisions based on technical issues. If you can come up with a solution that addresses the issues (please review the earlier discussion on the subject matter) then we will all be happy to see that merged.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
