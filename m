Date: Mon, 10 Apr 2006 13:20:59 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC/PATCH] Shared Page Tables [0/2]
In-Reply-To: <200ED4FEFEB8AA8427120DE7@[10.1.1.4]>
Message-ID: <Pine.LNX.4.64.0604101320100.24029@schroedinger.engr.sgi.com>
References: <1144685588.570.35.camel@wildcat.int.mccr.org>
 <Pine.LNX.4.64.0604101020230.22947@schroedinger.engr.sgi.com>
 <200ED4FEFEB8AA8427120DE7@[10.1.1.4]>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Hugh Dickins <hugh@veritas.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Adam Litke <agl@us.ibm.com>, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Mon, 10 Apr 2006, Dave McCracken wrote:

> The lock changes to hugetlb are only to support sharing of pmd pages when
> they contain hugetlb pages.  They just substitute the struct page lock for
> the page_table_lock, and are only about 30 lines of code.  Is this really
> worth separating out?

Ia64 does not use pmd pages for huge pages. It relies instead on a 
separate region. I wonder if this works on IA64.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
