Subject: Re: [PATCH 0/7] [RFC] hugetlb: pagetable_operations API
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <20070219183123.27318.27319.stgit@localhost.localdomain>
References: <20070219183123.27318.27319.stgit@localhost.localdomain>
Content-Type: text/plain
Date: Mon, 19 Feb 2007 19:43:01 +0100
Message-Id: <1171910581.3531.89.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2007-02-19 at 10:31 -0800, Adam Litke wrote:
> The page tables for hugetlb mappings are handled differently than page tables
> for normal pages.  Rather than integrating multiple page size support into the
> main VM (which would tremendously complicate the code) some hooks were created.
> This allows hugetlb special cases to be handled "out of line" by a separate
> interface.

ok it makes sense to clean this up.. what I don't like is that there
STILL are all the double cases... for this to work and be worth it both
the common case and the hugetlb case should be using the ops structure
always! Anything else and you're just replacing bad code with bad
code ;(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
