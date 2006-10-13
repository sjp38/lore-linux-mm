Message-ID: <452F3694.70104@yahoo.com.au>
Date: Fri, 13 Oct 2006 16:47:48 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 5/5] oom: invoke OOM killer from pagefault handler
References: <20061012120102.29671.31163.sendpatchset@linux.site>	<20061012120150.29671.48586.sendpatchset@linux.site>	<452E5B4D.7000402@sw.ru>	<20061012151907.GB18463@wotan.suse.de> <20061012150942.42e05898.akpm@osdl.org> <452F361D.1010306@yahoo.com.au>
In-Reply-To: <452F361D.1010306@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, Nick Piggin <npiggin@suse.de>, Kirill Korotaev <dev@sw.ru>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:

> What I especially have in mind here is the OOM_DISABLE and 
> panic_on_oom sysctl
> rather than expecting particularly much better general oom killing 
> behaviour.
> Suppose you have a critical failover node or heartbeat process or 
> something
> where you'd rather the system to panic and reboot instead of doing 
> something
> silly...


Oh, I already said that.

Well anyway, I'm not sure exactly how people use these tunables, but I 
expect
those that do, _really_ want them to work.

--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
