Date: Wed, 7 May 2008 19:57:05 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 03 of 11] invalidate_page outside PT lock
Message-ID: <20080507175705.GE18260@duo.random>
References: <patchbomb.1210170950@duo.random> <d60d200565abde6a8ed4.1210170953@duo.random> <20080507133943.3e76c899@bree.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080507133943.3e76c899@bree.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 07, 2008 at 01:39:43PM -0400, Rik van Riel wrote:
> Would it be an idea to merge them into one, so the first patch
> introduces the right conventions directly?

The only reason this isn't merged into one, is that this requires
non obvious (not difficult though) to the core VM code. I wanted to
keep an obviously safe approach for 2.6.26. The other conventions are
only needed by XPMEM and XPMEM can't work without all other patches anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
