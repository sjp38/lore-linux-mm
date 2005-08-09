From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [RFC][patch 0/2] mm: remove PageReserved
Date: Wed, 10 Aug 2005 06:52:38 +1000
References: <42F57FCA.9040805@yahoo.com.au> <200508100514.13672.phillips@arcor.de> <Pine.LNX.4.61.0508092112050.16395@goblin.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.61.0508092112050.16395@goblin.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200508100652.39241.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Wednesday 10 August 2005 06:17, Hugh Dickins wrote:
> There might be a case for packaging repeated arguments into structures
> (though several of these levels are inlined anyway), but that's some
> other exercise entirely, shouldn't get in the way of removing Reserved.

Agreed, an entirely separate question that I'd like to return to in time.  The 
existing herd of page table walkers is unnecessarily repetitious.

Regards,

Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
