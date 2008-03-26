Date: Tue, 25 Mar 2008 17:39:28 -0700 (PDT)
Message-Id: <20080325.173928.67585726.davem@davemloft.net>
Subject: Re: larger default page sizes...
From: David Miller <davem@davemloft.net>
In-Reply-To: <ed5aea430803251734u70f199w10951bc4f0db6262@mail.gmail.com>
References: <20080325.162244.61337214.davem@davemloft.net>
	<87tziu5q37.wl%peter@chubb.wattle.id.au>
	<ed5aea430803251734u70f199w10951bc4f0db6262@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: "David Mosberger-Tang" <dmosberger@gmail.com>
Date: Tue, 25 Mar 2008 18:34:13 -0600
Return-Path: <owner-linux-mm@kvack.org>
To: dmosberger@gmail.com
Cc: peterc@gelato.unsw.edu.au, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org, ianw@gelato.unsw.edu.au
List-ID: <linux-mm.kvack.org>

> Why not just repeat the PTEs for super-pages?

This is basically how we implement hugepages in the page
tables on sparc64.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
