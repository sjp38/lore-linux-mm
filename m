Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 83AE96B003D
	for <linux-mm@kvack.org>; Fri,  1 May 2009 11:24:45 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id C333B82C4A0
	for <linux-mm@kvack.org>; Fri,  1 May 2009 11:36:32 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id T5B3ljSy6SRc for <linux-mm@kvack.org>;
	Fri,  1 May 2009 11:36:32 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 5074F82C53A
	for <linux-mm@kvack.org>; Fri,  1 May 2009 11:36:07 -0400 (EDT)
Date: Fri, 1 May 2009 11:14:32 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH mmotm] mm: alloc_large_system_hash check order
In-Reply-To: <20090501150933.GE27831@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0905011114140.18324@qirst.com>
References: <Pine.LNX.4.64.0904292151350.30874@blonde.anvils> <20090430132544.GB21997@csn.ul.ie> <Pine.LNX.4.64.0905011202530.8513@blonde.anvils> <20090501140015.GA27831@csn.ul.ie> <alpine.DEB.1.10.0905010958090.18324@qirst.com>
 <20090501150933.GE27831@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, David Miller <davem@davemloft.net>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 1 May 2009, Mel Gorman wrote:

> But IIRC, the vmemmap code depends on architecture-specific help from
> vmemmap_populate() to place the map in the right place and it's not universally
> available. It's likely that similar would be needed to support large
> hash tables. I think the networking guys would need to be fairly sure
> the larger table would make a big difference before tackling the
> problem.

The same function could be used. Fallback to vmap is always possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
