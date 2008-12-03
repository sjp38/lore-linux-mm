Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id mB3NvaKU030440
	for <linux-mm@kvack.org>; Wed, 3 Dec 2008 16:57:36 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mB3Nx0CA208618
	for <linux-mm@kvack.org>; Wed, 3 Dec 2008 16:59:00 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mB3NwxHl014381
	for <linux-mm@kvack.org>; Wed, 3 Dec 2008 16:58:59 -0700
Date: Wed, 3 Dec 2008 17:58:58 -0600
From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC v10][PATCH 00/13] Kernel based checkpoint/restart
Message-ID: <20081203235858.GA27709@us.ibm.com>
References: <1227747884-14150-1-git-send-email-orenl@cs.columbia.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1227747884-14150-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>
List-ID: <linux-mm.kvack.org>

Quoting Oren Laadan (orenl@cs.columbia.edu):
> Checkpoint-restart (c/r): fixes a couple of bugs and a DoS issue
> (tested against v2.6.28-rc3).

Tests well for me.  Haven't tested mktree yet, will wait until you
re-send addressing feedback to do that.

thanks,
-serge

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
