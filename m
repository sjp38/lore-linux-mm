Date: Fri, 25 Apr 2003 13:32:18 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: TASK_UNMAPPED_BASE & stack location
Message-ID: <459930000.1051302738@[10.10.2.4]>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm mailing list <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@digeo.com>
List-ID: <linux-mm.kvack.org>

Is there any good reason we can't remove TASK_UNMAPPED_BASE, and just shove
libraries directly above the program text? Red Hat seems to have patches to
dynamically tune it on a per-processes basis anyway ...

Moreover, can we put the stack back where it's meant to be, below the
program text, in that wasted 128MB of virtual space? Who really wants 
> 128MB of stack anyway (and can't fix their app)?

I'm sure there's some horrible reason we can't do this ... would just like
to know what it is. If it's "standards compilance" I don't really believe
it - we don't comply with the standard now anyway ...

M.

PS. Motivation is creating large shmem segments for DBs.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
