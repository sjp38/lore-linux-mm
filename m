Received: from e500b.comp.nus.edu.sg (e500b.comp.nus.edu.sg [137.132.90.26])
	by x86unx3.comp.nus.edu.sg (8.9.1/8.9.1) with SMTP id MAA24077
	for <linux-mm@kvack.org>; Tue, 18 Jun 2002 12:15:48 +0800 (GMT-8)
Received: (from zoum@localhost)
	by sf0.comp.nus.edu.sg (8.8.5/8.8.5) id MAA25193
	for linux-mm@kvack.org; Tue, 18 Jun 2002 12:15:47 +0800 (GMT-8)
Date: Tue, 18 Jun 2002 12:15:47 +0800
From: Zou Min <zoum@comp.nus.edu.sg>
Subject: VM reference trace
Message-ID: <20020618121547.A15008@comp.nus.edu.sg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I am working on a problem which requires to get D: the number of distinct 
pages (from user files or dynamically allocated or used by the kernel, ...)
used by the kernel+user processes in a workload.

One way I thought of is to firstly generate a reference trace, i.e. a sequence
of virtual memory addresses accessed by the workload, and then count the
the number of distinct addresses in the trace. (assuming the addresses are 
page addresses).

In fact, I have found a library to do that, but it can only trace single
process in userland. And I have to modify, re-compile and re-link the program 
which I want to trace. That's a bit tedious.

So, I want to ask if there are any better utilities to generate the trace,
or any way to get the number D directly.

Thanks in advance!

-- 
regards,

ZM 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
