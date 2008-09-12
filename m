Message-ID: <48CA7AE4.2080007@linux-foundation.org>
Date: Fri, 12 Sep 2008 09:21:24 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: make do_move_pages() complexity linear
References: <48CA611A.8060706@inria.fr> <48CA727F.1050405@linux-foundation.org> <48CA748F.8020701@inria.fr>
In-Reply-To: <48CA748F.8020701@inria.fr>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brice Goglin <Brice.Goglin@inria.fr>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Nathalie Furmento <nathalie.furmento@labri.fr>
List-ID: <linux-mm.kvack.org>

Brice Goglin wrote:

> I don't think so. If this happens, the while loop will skip those pages.
> (while in the regular case, the while loop does 0 iterations).
> The while loop is still here to make sure we are processing the right pm
> entry. What the patch changes is only that we don't uselessly look at
> the already-processed beginning of pm.

Ahh.. I missed that.

Acked-by: Christoph Lameter <cl@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
