Date: Tue, 3 Feb 2004 02:33:59 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.2-rc3-mm1
Message-Id: <20040203023359.59dc0613.akpm@osdl.org>
In-Reply-To: <20040202235817.5c3feaf3.akpm@osdl.org>
References: <20040202235817.5c3feaf3.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Nick Piggin <piggin@cyberone.com.au>
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@osdl.org> wrote:
>
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.2-rc3/2.6.2-rc3-mm1/

There were some problems with vm-rss-limit-enforcement.patch.  I've backed
that out and uploaded 2.6.2-rc3-mm1-1.  This is mainly for Nick to patch
against, but if pageout performance problems are noticed, please try -1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
