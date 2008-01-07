Date: Mon, 7 Jan 2008 20:26:40 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Subject: Re: [PATCH 03 of 11] prevent oom deadlocks during read/write
	operations
Message-ID: <20080107192640.GO10749@v2.random>
References: <71f1d848763c80f336f7.1199326149@v2.random> <Pine.LNX.4.64.0801071115210.23617@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801071115210.23617@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 07, 2008 at 11:15:49AM -0800, Christoph Lameter wrote:
> This means that killing a process with SIGKILL from user land may lead to 
> OOM handling being triggered in the VM?

Well, Andrew added the status=-ENOMEM in his version, but userland
should never get to see the status. So this should only have the
effect of being more reactive to SIGKILL. Alternatively TIF_MEMDIE
could be checked, but checking sigkill sounded nicer there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
