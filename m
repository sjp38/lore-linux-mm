Date: Fri, 24 Dec 2004 09:33:38 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Prezeroing V2 [2/4]: add second parameter to clear_page() for all arches
Message-ID: <20041224083337.GA1043@openzaurus.ucw.cz>
References: <B8E391BBE9FE384DAA4C5C003888BE6F02900FBD@scsmsx401.amr.corp.intel.com> <41C20E3E.3070209@yahoo.com.au> <Pine.LNX.4.58.0412211154100.1313@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0412231119540.31791@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0412231132170.31791@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0412231133130.31791@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0412231133130.31791@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-ia64@vger.kernel.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi!

> o Extend clear_page to take an order parameter for all architectures.
> 

I believe you sould leave clear_page() as is, and introduce
clear_pages() with two arguments.
				Pavel

> -extern void clear_page (void *page);
> +extern void clear_page (void *page, int order);
>  extern void copy_page (void *to, void *from);
> 

-- 
64 bytes from 195.113.31.123: icmp_seq=28 ttl=51 time=448769.1 ms         

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
