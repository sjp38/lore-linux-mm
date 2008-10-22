Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m9M32jjW014206
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 23:02:46 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9M32juI145964
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 21:02:45 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9M32jWN030462
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 21:02:45 -0600
Subject: Re: [RFC v7][PATCH 2/9] General infrastructure for checkpoint
	restart
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20081022025513.GA7504@caradoc.them.org>
References: <1224481237-4892-1-git-send-email-orenl@cs.columbia.edu>
	 <1224481237-4892-3-git-send-email-orenl@cs.columbia.edu>
	 <20081021124130.a002e838.akpm@linux-foundation.org>
	 <20081021202410.GA10423@us.ibm.com> <48FE82DF.6030005@cs.columbia.edu>
	 <20081022025513.GA7504@caradoc.them.org>
Content-Type: text/plain
Date: Tue, 21 Oct 2008 20:02:43 -0700
Message-Id: <1224644563.1848.232.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Jacobowitz <dan@debian.org>
Cc: Oren Laadan <orenl@cs.columbia.edu>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, mingo@elte.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, hpa@zytor.com, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

On Tue, 2008-10-21 at 22:55 -0400, Daniel Jacobowitz wrote:
> I haven't been following - but why this whole container restriction?
> Checkpoint/restart of individual processes is very useful too.
> There are issues with e.g. IPC, but I'm not convinced they're
> substantially different than the issues already present for a
> container.

Containers provide isolation.  Once you have isolation, you have a
discrete set of resources which you can checkpoint/restart.

Let's say you have a process you want to checkpoint.  If it uses a
completely discrete IPC namespace, you *know* that nothing else depends
on those IPC ids.  We don't even have to worry about who might have been
using them and when.

Also think about pids.  Without containers, how can you guarantee a
restarted process that it can regain the same pid?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
