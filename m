Date: Tue, 13 Nov 2007 13:38:11 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Sparsemem: Do not reserve section flags if VMEMMAP is in use
In-Reply-To: <20071113134603.5b4b0f24.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0711131336500.3714@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0711121944400.30269@schroedinger.engr.sgi.com>
 <20071113134603.5b4b0f24.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 13 Nov 2007, KAMEZAWA Hiroyuki wrote:

> I like this. but it may safe to add this definition to do this..
> 
> ==
> #if SECTIONS_WIDTH > 0
> static inline page_to_section(struct page *page)
> {
> 	return pfn_to_section(page_to_pfn(page));
> }
> else
> ....
> #endif
> ==

Well that is currently not done for !SPARSEMEM configuration where 
SECTIONS_WIDTH is also zero. So I left it as is.

> page_to_section is used in page_to_nid() if NODE_NOT_IN_PAGE_FLAGS=y.
> (I'm not sure exact config dependency.)

NODE_NOT_IN_PAGE_FLAGS=y only occurs when flag bits are 
taken away by sparsemem for the section bits.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
