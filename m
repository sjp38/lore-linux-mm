Date: Thu, 25 Mar 2004 19:38:22 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.5-rc2-mm3 blizzard of "bad: scheduling while atomic" with PREEMPT
Message-ID: <20040325183822.GA11088@elte.hu>
References: <1080237733.2269.31.camel@spc0.esa.lanl.gov> <20040325103506.19129deb.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040325103506.19129deb.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Steven Cole <elenstev@mesatop.com>, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

* Andrew Morton <akpm@osdl.org> wrote:

> >  Recompiling without PREEMPT made this go away.
> 
> err, yes.  Ingo broke it ;)

ugh. Checking it.

	Ingo
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
