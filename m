Subject: Re: [PATCH 0/7] [RFC] hugetlb: pagetable_operations API
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1171910581.3531.89.camel@laptopd505.fenrus.org>
References: <20070219183123.27318.27319.stgit@localhost.localdomain>
	 <1171910581.3531.89.camel@laptopd505.fenrus.org>
Content-Type: text/plain
Date: Wed, 21 Feb 2007 06:54:57 +1100
Message-Id: <1172001297.18571.130.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2007-02-19 at 19:43 +0100, Arjan van de Ven wrote:
> On Mon, 2007-02-19 at 10:31 -0800, Adam Litke wrote:
> > The page tables for hugetlb mappings are handled differently than page tables
> > for normal pages.  Rather than integrating multiple page size support into the
> > main VM (which would tremendously complicate the code) some hooks were created.
> > This allows hugetlb special cases to be handled "out of line" by a separate
> > interface.
> 
> ok it makes sense to clean this up.. what I don't like is that there
> STILL are all the double cases... for this to work and be worth it both
> the common case and the hugetlb case should be using the ops structure
> always! Anything else and you're just replacing bad code with bad
> code ;(

I don't fully agree. I think it makes sense to have the "special" case
be a function pointer and the "normal" case stay where it is for
performances. You don't want to pay the cost of the function pointer
call in the normal case do you ?

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
