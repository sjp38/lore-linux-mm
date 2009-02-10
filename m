Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id AE29A6B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 12:06:05 -0500 (EST)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n1AH3li8027530
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 10:03:47 -0700
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n1AH5nHA230550
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 10:05:50 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1AH5nnx024213
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 10:05:49 -0700
Subject: Re: [RFC v13][PATCH 00/14] Kernel based checkpoint/restart
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>
Content-Type: text/plain
Date: Tue, 10 Feb 2009 09:05:47 -0800
Message-Id: <1234285547.30155.6.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@osdl.org>, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-01-27 at 12:07 -0500, Oren Laadan wrote:
> Checkpoint-restart (c/r): a couple of fixes in preparation for 64bit
> architectures, and a couple of fixes for bugss (comments from Serge
> Hallyn, Sudakvev Bhattiprolu and Nathan Lynch). Updated and tested
> against v2.6.28.
> 
> Aiming for -mm.

Is there anything that we're waiting on before these can go into -mm?  I
think the discussion on the first few patches has died down to almost
nothing.  They're pretty reviewed-out.  Do they need a run in -mm?  I
don't think linux-next is quite appropriate since they're not _quite_
aimed at mainline yet.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
