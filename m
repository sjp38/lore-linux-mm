Date: Mon, 7 Jan 2008 11:15:49 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 03 of 11] prevent oom deadlocks during read/write operations
In-Reply-To: <71f1d848763c80f336f7.1199326149@v2.random>
Message-ID: <Pine.LNX.4.64.0801071115210.23617@schroedinger.engr.sgi.com>
References: <71f1d848763c80f336f7.1199326149@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@cpushare.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

This means that killing a process with SIGKILL from user land may lead to 
OOM handling being triggered in the VM?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
