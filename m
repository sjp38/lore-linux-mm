Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 61D066B0159
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 05:49:54 -0400 (EDT)
Message-ID: <1340358580.18025.53.camel@twins>
Subject: Re: [PATCH -mm v2 04/11] rbtree: add helpers to find nearest uncle
 node
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 22 Jun 2012 11:49:40 +0200
In-Reply-To: <1340315835-28571-5-git-send-email-riel@surriel.com>
References: <1340315835-28571-1-git-send-email-riel@surriel.com>
	 <1340315835-28571-5-git-send-email-riel@surriel.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@surriel.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>

On Thu, 2012-06-21 at 17:57 -0400, Rik van Riel wrote:
> It is useful to search an augmented rbtree based on the augmented
> data, ie. not using the sort key as the primary search criterium.
> However, we may still need to limit our search to a sub-part of the
> whole tree, using the sort key as limiters where we can search.
>=20
> In that case, we may need to stop searching in one part of the tree,
> and continue the search at the nearest (great-?)uncle node in a particula=
r
> direction.
>=20
> Add helper functions to find the nearest uncle node.

I don't think we need these at all, in fact, I cannot prove your lookup
function is O(log n) at all, since the uncle might not have a suitable
max gap size, so you might need to find yet another uncle etc.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
