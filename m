Date: Fri, 17 Dec 2004 15:54:43 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [patch] kill off ARCH_HAS_ATOMIC_UNSIGNED (take 2)
Message-Id: <20041217155443.0a370ed7.pj@sgi.com>
In-Reply-To: <1103308048.4450.123.camel@localhost>
References: <Pine.LNX.4.44.0412171814050.10470-100000@localhost.localdomain>
	<1103308048.4450.123.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: hugh@veritas.com, linux-mm@kvack.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

Dave wrote:
>  	printk(KERN_EMERG "flags:0x%0*lx mapping:%p mapcount:%d count:%d\n",
> -		(int)(2*sizeof(page_flags_t)), (unsigned long)page->flags,
> +		(int)(2*sizeof(unsigned long)), page->flags,
>  		page->mapping, page_mapcount(page), page_count(page));

I've a slight preference for:

	printk(KERN_EMERG "flags:0x%0*lx mapping:%p mapcount:%d count:%d\n",
		(int)(2*sizeof(page->flags)), page->flags,
		page->mapping, page_mapcount(page), page_count(page));

or perhaps even a little better:

	printk(KERN_EMERG "flags:0x%08lx mapping:%p mapcount:%d count:%d\n",
				page->flags, page->mapping,
				page_mapcount(page), page_count(page));

Most plain unsigned longs are displayed with some variant of %8lx, not a
%*lx variable sized format.  And in general, the plainer the code, the
quicker the reader can understand it.

But if you don't find my nit picking both pleasing and convenient, don't
hesitate to dismiss it.  It's no biggie, and my comment is just a drive
by shooting so has little standing.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.650.933.1373, 1.925.600.0401
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
