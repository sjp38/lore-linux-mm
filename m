Date: Wed, 16 Nov 2005 07:00:24 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: pfn_to_nid under CONFIG_SPARSEMEM and CONFIG_NUMA
Message-ID: <20051116130024.GD4573@lnx-holt.americas.sgi.com>
References: <20051115221003.GA2160@w-mikek2.ibm.com> <20051116115548.EE18.Y-GOTO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051116115548.EE18.Y-GOTO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Mike Kravetz <kravetz@us.ibm.com>, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>, Anton Blanchard <anton@samba.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 16, 2005 at 12:14:18PM +0900, Yasunori Goto wrote:
> static inline int pfn_to_nid(unsigned long pfn)
> {
> 	return page_to_nid(pfn_to_page(pfn));

But that does not work if the pfn points to something which does not
have a struct page behind it (uncached memory on ia64 for instance).
At the very least you would need to ensure pfn_to_page returns a  struct
page * before continuing blindly.

> page_to_nid() and pfn_to_page() is well defined.
> Probably, this will work on all architecture.
> So, just we should check this should be used after that memmap
> is initialized.

Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
