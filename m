Date: Wed, 3 Nov 2004 02:35:11 +0100
From: Andrea Arcangeli <andrea@novell.com>
Subject: Re: fix iounmap and a pageattr memleak (x86 and x86-64)
Message-ID: <20041103013511.GC3571@dualathlon.random>
References: <4187FA6D.3070604@us.ibm.com> <20041102220720.GV3571@dualathlon.random> <41880E0A.3000805@us.ibm.com> <4188118A.5050300@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4188118A.5050300@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@suse.de>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 02, 2004 at 03:00:26PM -0800, Dave Hansen wrote:
> just sent out, I just wanted to demonstrate what solves my immediate 
> problem.

sure ;)

that's like disabling the config option, the only point of
change_page_attr is to split the direct mapping, it does nothing on
highmem, it actually BUGS() (and it wasn't one of my new bugs ;):

#ifdef CONFIG_HIGHMEM
	if (page >= highmem_start_page) 
		BUG(); 
#endif
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
