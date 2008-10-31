Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id m9VDwDlu014010
	for <linux-mm@kvack.org>; Fri, 31 Oct 2008 07:58:13 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9VDwr5f072934
	for <linux-mm@kvack.org>; Fri, 31 Oct 2008 07:58:53 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9VDwO8A018682
	for <linux-mm@kvack.org>; Fri, 31 Oct 2008 07:58:24 -0600
Date: Fri, 31 Oct 2008 08:58:52 -0500
From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC v8][PATCH 11/12] External checkpoint of a task other than
	ourself
Message-ID: <20081031135852.GA11641@us.ibm.com>
References: <1225374675-22850-1-git-send-email-orenl@cs.columbia.edu> <1225374675-22850-12-git-send-email-orenl@cs.columbia.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1225374675-22850-12-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>
List-ID: <linux-mm.kvack.org>

Quoting Oren Laadan (orenl@cs.columbia.edu):
> Now we can do "external" checkpoint, i.e. act on another task.
> 
> sys_checkpoint() now looks up the target pid (in our namespace) and
> checkpoints that corresponding task. That task should be the root of
> a container.
> 
> sys_restart() remains the same, as the restart is always done in the
> context of the restarting task.
> 
> Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>

(Have looked this up and down, and it looks good, so while it's the
easiest piece of code to blame for the BUG() I'm getting, it doesn't
seem possible that it is)

Acked-by: Serge Hallyn <serue@us.ibm.com>

thanks, Oren.

-serge

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
