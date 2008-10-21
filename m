Subject: Re: mlock: mlocked pages are unevictable
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1224621015.6724.6.camel@twins>
References: <200810201659.m9KGxtFC016280@hera.kernel.org>
	 <20081021151301.GE4980@osiris.boeblingen.de.ibm.com>
	 <2f11576a0810210851g6e0d86benef5d801871886dd7@mail.gmail.com>
	 <2f11576a0810211018g5166c1byc182f1194cfdd45d@mail.gmail.com>
	 <1224621015.6724.6.camel@twins>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Tue, 21 Oct 2008 22:48:06 +0200
Message-Id: <1224622086.6724.8.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, Oleg Nesterov <oleg@tv-sign.ru>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-10-21 at 22:30 +0200, Peter Zijlstra wrote:

> The problem appears to be calling flush_work(), which is rather heavy
> handed. We could do schedule_on_each_cpu() using a completion.
> 
> Which I think is a nicer solution (if sufficient of course).

Ah, never mind, the flush_work() is already doing the right thing using
barriers and completions.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
