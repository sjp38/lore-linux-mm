Subject: Re: NOPAGE_RETRY and 2.6.19
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20061005160634.5932ba78.akpm@osdl.org>
References: <1160088050.22232.90.camel@localhost.localdomain>
	 <20061005160634.5932ba78.akpm@osdl.org>
Content-Type: text/plain
Date: Fri, 06 Oct 2006 09:38:19 +1000
Message-Id: <1160091499.22232.98.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2006-10-05 at 16:06 -0700, Andrew Morton wrote:
> On Fri, 06 Oct 2006 08:40:50 +1000
> Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
> 
> > Any chance that can be merged in 2.6.19 ?
> 
> Not if you don't show it to anyone ;)

Didn' I send it to you last week ?

> I renamed your NOPAGE_RETRY to NOPAGE_REFAULT.  Because I think that
> better communicates the fact that it returns all the way to userspace to
> redo the fault.  Later, a NOPAGE_RETRY would be a lower-level thing which
> doesn't redo the fault.

Ok.

Thanks,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
