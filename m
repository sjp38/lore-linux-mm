Date: Tue, 29 Apr 2008 10:00:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: 2.6.24 regression: deadlock on coredump of big process
Message-Id: <20080429100048.3e78b1ba.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4815E932.1040903@cybernetics.com>
References: <4815E932.1040903@cybernetics.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, 28 Apr 2008 11:11:46 -0400
Tony Battersby <tonyb@cybernetics.com> wrote:

> Below is the program that triggers the deadlock; compile with
> -D_REENTRANT -lpthread.
> 
What happens if you changes size of stack (of pthreads) smaller ?
(maybe ulimit -s will work also for threads.)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
