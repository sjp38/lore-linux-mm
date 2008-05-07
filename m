Date: Wed, 7 May 2008 13:39:43 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 03 of 11] invalidate_page outside PT lock
Message-ID: <20080507133943.3e76c899@bree.surriel.com>
In-Reply-To: <d60d200565abde6a8ed4.1210170953@duo.random>
References: <patchbomb.1210170950@duo.random>
	<d60d200565abde6a8ed4.1210170953@duo.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 07 May 2008 16:35:53 +0200
Andrea Arcangeli <andrea@qumranet.com> wrote:

> # HG changeset patch
> # User Andrea Arcangeli <andrea@qumranet.com>
> # Date 1210115129 -7200
> # Node ID d60d200565abde6a8ed45271e53cde9c5c75b426
> # Parent  c5badbefeee07518d9d1acca13e94c981420317c
> invalidate_page outside PT lock
> 
> Moves all mmu notifier methods outside the PT lock (first and not last
> step to make them sleep capable).

This patch appears to undo some of the changes made by patch 01/11.

Would it be an idea to merge them into one, so the first patch
introduces the right conventions directly?

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
