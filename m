Date: Mon, 10 Feb 2003 21:02:32 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: hot and cold pages
Message-ID: <74860000.1044939751@[10.10.2.4]>
In-Reply-To: <1044976347.13957.19.camel@amol.in.ishoni.com>
References: <1044976347.13957.19.camel@amol.in.ishoni.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Amol Kumar Lad <amolk@ishoni.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>   I have a small question regarding 'per_cpu_pages' . What is
> significance if maintaining 'hot' pages and 'cold' pages list. Are hot
> pages something to do with L2 cache (on x86) ?

Yup, pages that are thought to be L2 cache hot (or cold, respectively) for
that CPU as a lifo stack.

> After going through code, I found out, any new page allocation (for file
> read)is from cold page list and zero order pages are generally freed to
> hot page list

Right ... if you're going to DMA into it, you might as well use a cold page
- no advantage to using a hot one. Pages newly freed stand a good chance of
being hot, so they're put into the hot list.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
