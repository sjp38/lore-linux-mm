Message-ID: <3B380E7B.6609337F@uow.edu.au>
Date: Tue, 26 Jun 2001 14:24:27 +1000
From: Andrew Morton <andrewm@uow.edu.au>
MIME-Version: 1.0
Subject: Re: [RFC] VM statistics to gather
References: <Pine.LNX.4.33L.0106252002560.23373-100000@duckman.distro.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> Hi,
> 
> I am starting the process of adding more detailed instrumentation
> to the VM subsystem and am wondering which statistics to add.
> A quick start of things to measure are below, but I've probably
> missed some things. Comments are welcome ...

Neat.

- bdflush wakeups
- pages written via page_launder's writepage by kswapd
- pages written via page_launder's writepage by non-PF_MEMALLOC
  tasks.  (ext3 has an interest in this because of nasty cross-fs
  reentrancy and journal overflow problems with writepage)
- shrink_icache call rate
- amount of stuff freed by shrink_icache
- ditto for shrink_dcache.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
