Date: Tue, 14 Dec 2004 12:25:11 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Anticipatory prefaulting in the page fault handler V1
In-Reply-To: <200412142124.11685.amgta@yacht.ocn.ne.jp>
Message-ID: <Pine.LNX.4.58.0412141224520.3044@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.44.0411221457240.2970-100000@localhost.localdomain>
 <200412132330.23893.amgta@yacht.ocn.ne.jp> <Pine.LNX.4.58.0412130905140.360@schroedinger.engr.sgi.com>
 <200412142124.11685.amgta@yacht.ocn.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Akinobu Mita <amgta@yacht.ocn.ne.jp>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, nickpiggin@yahoo.com.au, Jeff Garzik <jgarzik@pobox.com>, torvalds@osdl.org, hugh@veritas.com, benh@kernel.crashing.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 14 Dec 2004, Akinobu Mita wrote:

> This is why I inserted pte_none() for each page_table in case of
> read fault too.
>
> If read access fault occured for the address "addr".
> It is completely unnecessary to check by pte_none() to the page_table
> for "addr". Because page_table_lock has never been released until
> do_anonymous_page returns (in case of read access fault)
>
> But there is not any guarantee that the page_tables for addr+PAGE_SIZE,
> addr+2*PAGE_SIZE, ...  have not been mapped yet.

Right. Thanks for pointing that out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
