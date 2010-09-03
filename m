Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D12FB6B0047
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 02:09:41 -0400 (EDT)
Date: Fri, 3 Sep 2010 08:09:27 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/2] Add trace points to mmap, munmap, and brk
Message-ID: <20100903060927.GA19074@elte.hu>
References: <20100721223359.8710.A69D9226@jp.fujitsu.com>
 <20100727110904.GA6519@mgebm.net>
 <20100727201644.2F46.A69D9226@jp.fujitsu.com>
 <20100902134827.GA6957@mgebm.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100902134827.GA6957@mgebm.net>
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <emunson@mgebm.net>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, akpm@linux-foundation.org, mingo@redhat.com, hugh.dickins@tiscali.co.uk, riel@redhat.com, peterz@infradead.org, anton@samba.org, hch@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


* Eric B Munson <emunson@mgebm.net> wrote:

> Sorry for the long delay, the enter/exit routines are not compatible 
> with the information that these new trace points provides.  When 
> tracing mmap, for instance, the addr and len arguments can be altered 
> by the function.  If you use the enter/exit trace points you would not 
> see this as the arguments are sampled at function entrance and not 
> given again on exit.  Also, the new trace points are only hit on 
> function success, the exit trace point happens any time you leave the 
> system call.

Would it be feasible to use enter/exit information as the main source of 
events - and only add new tracepoints for the _missing_ information? 
(such as when mmap arguments change)

Then user-space can combine the two. The new tracepoints would also 
carry useful information in themselves: they would show the cases where 
user-space did not get what it wished. (or so)

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
