Date: Tue, 17 Jun 2008 19:33:32 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH][RFC] fix kernel BUG at mm/migrate.c:719! in 2.6.26-rc5-mm3
In-Reply-To: <1213724798.8707.41.camel@lts-notebook>
Message-ID: <Pine.LNX.4.64.0806171925200.21436@blonde.site>
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org>
 <20080617163501.7cf411ee.nishimura@mxp.nes.nec.co.jp> <1213724798.8707.41.camel@lts-notebook>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 17 Jun 2008, Lee Schermerhorn wrote:
> 
> Now I wonder if the assertion that newpage count == 1 could be violated?
> I don't see how.  We've just allocated and filled it and haven't
> unlocked it yet, so we should hold the only reference.  Do you agree?

Disagree: IIRC, excellent example of the kind of assumption
that becomes invalid with Nick's speculative page references.

Someone interested in the previous use of the page may have
incremented the refcount, and in due course will find that
it's got reused for something else, and will then back off.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
