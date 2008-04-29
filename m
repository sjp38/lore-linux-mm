Message-ID: <48172C72.1000501@cybernetics.com>
Date: Tue, 29 Apr 2008 10:10:58 -0400
From: Tony Battersby <tonyb@cybernetics.com>
MIME-Version: 1.0
Subject: Re: 2.6.24 regression: deadlock on coredump of big process
References: <4815E932.1040903@cybernetics.com> <20080429100048.3e78b1ba.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080429100048.3e78b1ba.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Mon, 28 Apr 2008 11:11:46 -0400
> Tony Battersby <tonyb@cybernetics.com> wrote:
>
>   
>> Below is the program that triggers the deadlock; compile with
>> -D_REENTRANT -lpthread.
>>
>>     
> What happens if you changes size of stack (of pthreads) smaller ?
> (maybe ulimit -s will work also for threads.)
>
> Thanks,
> -Kame
>
>
>   

If I leave more memory free by changing the argument to
malloc_all_but_x_mb(), then I have to increase the number of threads
required to trigger the deadlock.  Changing the thread stack size via
setrlimit(RLIMIT_STACK) also changes the number of threads that are
required to trigger the deadlock.  For example, with
malloc_all_but_x_mb(16) and the default stack size of 8 MB, <= 5 threads
will coredump successfully, and >= 6 threads will deadlock.  With
malloc_all_but_x_mb(16) and a reduced stack size of 4096 bytes, <= 8
threads will coredump successfully, and >= 9 threads will deadlock.

Also note that the "free" command reports 10 MB free memory while the
program is running before the segfault is triggered.

Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
