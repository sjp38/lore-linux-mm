Date: Thu, 11 Nov 2004 04:11:11 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: follow_page()
Message-Id: <20041111041111.185c29e5.akpm@osdl.org>
In-Reply-To: <419353D5.2080902@yahoo.com.au>
References: <20041111024015.7c50c13d.akpm@osdl.org>
	<1100170570.2646.27.camel@laptop.fenrus.org>
	<20041111030634.1d06a7c1.akpm@osdl.org>
	<1100171453.2646.29.camel@laptop.fenrus.org>
	<419353D5.2080902@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: arjan@infradead.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <nickpiggin@yahoo.com.au> wrote:
>
> Kill it..?

Think so.  We'd need to review all callers to make sure that they really
are marking pages dirty after modifying them.  Right now someone may just
be feeling lucky.

(looks at access_process_vm, wonders why it isn't doing flush_dcache_page).
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
