Subject: Re: [PATCH] Remove OOM killer from try_to_free_pages /
	all_unreclaimable braindamage
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <20041106154415.GD3851@dualathlon.random>
References: <20041105200118.GA20321@logos.cnet>
	 <200411051532.51150.jbarnes@sgi.com>
	 <20041106012018.GT8229@dualathlon.random>
	 <20041106100516.GA22514@logos.cnet>
	 <20041106154415.GD3851@dualathlon.random>
Content-Type: text/plain
Message-Id: <1099756374.2814.18.camel@laptop.fenrus.org>
Mime-Version: 1.0
Date: Sat, 06 Nov 2004 16:52:54 +0100
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@novell.com>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Jesse Barnes <jbarnes@sgi.com>, Andrew Morton <akpm@osdl.org>, Nick Piggin <piggin@cyberone.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> yes. oom killing should be avoided as far as we can avoid it. Ideally we
> should never invoke the oom killer and we should always return -ENOMEM
> to applications. If a syscall runs oom then we can return -ENOMEM and
> handle the failure gracefully instead of getting a sigkill.
> 
> With 2.4 -ENOMEM is returned and the machine doesn't deadlock when the
> zone normal is full and that works fine.

the harder case is where you do an mmap and then in the fault path find out that there's no memory to allocate the PMD ...
killing the task that has that failing isn't per se the right answer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
