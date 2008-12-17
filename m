Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A8EE36B0093
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 19:11:29 -0500 (EST)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id mBH0CFkr012248
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 17:12:15 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mBH0D8nM140236
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 17:13:08 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mBH0D6nQ011785
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 17:13:08 -0700
Subject: Re: [RFC v11][PATCH 03/13] General infrastructure for checkpoint
	restart
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <49482F14.1040407@google.com>
References: <1228498282-11804-1-git-send-email-orenl@cs.columbia.edu>
	 <1228498282-11804-4-git-send-email-orenl@cs.columbia.edu>
	 <49482394.10006@google.com> <1229465641.17206.350.camel@nimitz>
	 <49482F14.1040407@google.com>
Content-Type: text/plain
Date: Tue, 16 Dec 2008 16:13:03 -0800
Message-Id: <1229472783.17206.358.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mike Waychison <mikew@google.com>
Cc: jeremy@goop.org, arnd@arndb.de, containers@lists.linux-foundation.org, "H. Peter Anvin" <hpa@zytor.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linux Torvalds <torvalds@osdl.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-12-16 at 14:43 -0800, Mike Waychison wrote:
> Hmm, if I'm understanding you correctly, adding ref counts explicitly 
> (like you suggest below)  would be used to let a lower layer defer 
> writes.  Seems like this could be just as easily done with explicits 
> kmallocs and transferring ownership of the allocated memory to the 
> in-kernel representation handling layer below (which in turn queues the 
> data structures for writes).

Yup, that's true.  We'd effectively shift the burden of freeing those
buffers into the cr_write() (or whatever we call it) function.  

But, I'm just thinking about the sys_checkpoint() side.  I need to go
look at the restart code too.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
