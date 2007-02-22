Date: Thu, 22 Feb 2007 15:09:29 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [RFC] [PATCH 2.6.20-mm2] Optionally inherit mlockall() semantics
 across fork()/exec()
In-Reply-To: <1172178237.5341.38.camel@localhost>
Message-ID: <Pine.LNX.4.64.0702221507080.22567@schroedinger.engr.sgi.com>
References: <1172178237.5341.38.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 22 Feb 2007, Lee Schermerhorn wrote:

> Add an int to mm_struct to remember inheritance of future locks.

Should that not go into the task_struct rather than into mm_struct? 
If you run your gizmo on a thread then all other threads of the process 
will also be pinned.

Or put it into the vma like VM_MLOCK and inherit it when vmas are copied.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
