Date: Fri, 21 Feb 2003 14:22:33 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: Silly question: How to map a user space page in kernel space?
Message-ID: <296040000.1045866153@flay>
In-Reply-To: <A46BBDB345A7D5118EC90002A5072C780A7D5194@orsmsx116.jf.intel.com>
References: <A46BBDB345A7D5118EC90002A5072C780A7D5194@orsmsx116.jf.intel.com
 >
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Perez-Gonzalez, Inaky" <inaky.perez-gonzalez@intel.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Got a naive question I cannot find the answer for: 
> 
> I have a user space page (I know the 'struct page *' and I did a
> get_page() on it so it doesn't go away to swap) and I need to be able to
> access it with normal pointers (to do a bunch of atomic operations on
> it). I cannot use get_user() and friends, just pointers.
> 
> So, the question is, how can I map it into the kernel space in a portable
> manner? Am I missing anything very basic here?
> 
> Thanks in advance :)
> 
> PS: I suspect remap_page_range() is going to be involved, but I cannot see
> how.

kmap or kmap_atomic

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
