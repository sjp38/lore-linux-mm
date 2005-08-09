Subject: Re: [RFC][patch 0/2] mm: remove PageReserved
From: Nigel Cunningham <ncunningham@cyclades.com>
Reply-To: ncunningham@cyclades.com
In-Reply-To: <200508090710.00637.phillips@arcor.de>
References: <42F57FCA.9040805@yahoo.com.au>
	 <200508090710.00637.phillips@arcor.de>
Content-Type: text/plain
Message-Id: <1123562392.4370.112.camel@localhost>
Mime-Version: 1.0
Date: Tue, 09 Aug 2005 14:39:52 +1000
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Hi.

On Tue, 2005-08-09 at 07:09, Daniel Phillips wrote:
> > It doesn't look like they'll be able to easily free up a page
> > flag for 2 reasons. First, PageReserved will probably be kept
> > around for at least one release. Second, swsusp and some arch
> > code (ioremap) wants to know about struct pages that don't point
> > to valid RAM - currently they use PageReserved, but we'll probably
> > just introduce a PageValidRAM or something when PageReserved goes.

Changing the e820 code so it sets PageNosave instead of PageReserved,
along with a couple of modifications in swsusp itself should get rid of
the swsusp dependency.

Regards,

Nigel
-- 
Evolution.
Enumerate the requirements.
Consider the interdependencies.
Calculate the probabilities.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
