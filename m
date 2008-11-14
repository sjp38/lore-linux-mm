Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id mAE3eqHZ014524
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 20:40:52 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAE3fW22158924
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 20:41:32 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mAE3fVP7003890
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 20:41:32 -0700
Date: Thu, 13 Nov 2008 21:41:30 -0600
From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC v9][PATCH 12/13] Checkpoint multiple processes
Message-ID: <20081114034130.GA14171@us.ibm.com>
References: <1226335060-7061-1-git-send-email-orenl@cs.columbia.edu> <1226335060-7061-13-git-send-email-orenl@cs.columbia.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1226335060-7061-13-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>
List-ID: <linux-mm.kvack.org>

Quoting Oren Laadan (orenl@cs.columbia.edu):
> Checkpointing of multiple processes works by recording the tasks tree
> structure below a given task (usually this task is the container init).
> 
> For a given task, do a DFS scan of the tasks tree and collect them
> into an array (keeping a reference to each task). Using DFS simplifies
> the recreation of tasks either in user space or kernel space. For each
> task collected, test if it can be checkpointed, and save its pid, tgid,
> and ppid.
> 
> The actual work is divided into two passes: a first scan counts the
> tasks, then memory is allocated and a second scan fills the array.
> 
> The logic is suitable for creation of processes during restart either
> in userspace or by the kernel.
> 
> Currently we ignore threads and zombies, as well as session ids.
> 
> Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>

Looks good.

Acked-by: Serge Hallyn <serue@us.ibm.com>

thanks,
-serge

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
