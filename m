Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id QAA21234
	for <linux-mm@kvack.org>; Tue, 11 Mar 2003 16:30:46 -0800 (PST)
Date: Tue, 11 Mar 2003 16:25:52 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: Free pages leaking in 2.5.64?
Message-Id: <20030311162552.7f78e764.akpm@digeo.com>
In-Reply-To: <1047376995.1692.23.camel@laptop-linux.cunninghams>
References: <1047376995.1692.23.camel@laptop-linux.cunninghams>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nigel Cunningham <ncunningham@clear.net.nz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Nigel Cunningham <ncunningham@clear.net.nz> wrote:
>
> Hi all.
> 
> I've come across the following problem in 2.5.64. Here's example output.
> The header is one page - all messages only have a single call to
> get_zeroed_page between the printings and the same code works as

nr_free_pages() does not account for the pages in the per-cpu head arrays. 

You can make the numbers look right via drain_local_pages(), but that is only
100% reliable on uniprocessor with interrupts disabled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
