Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m9DGhlX0002245
	for <linux-mm@kvack.org>; Mon, 13 Oct 2008 12:43:47 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9DGhlpC202236
	for <linux-mm@kvack.org>; Mon, 13 Oct 2008 12:43:47 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9DGhkbf025321
	for <linux-mm@kvack.org>; Mon, 13 Oct 2008 12:43:47 -0400
Subject: Re: [RFC v6][PATCH 0/9] Kernel based checkpoint/restart
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <48F30315.1070909@fr.ibm.com>
References: <1223461197-11513-1-git-send-email-orenl@cs.columbia.edu>
	 <20081009124658.GE2952@elte.hu> <1223557122.11830.14.camel@nimitz>
	 <20081009131701.GA21112@elte.hu> <1223559246.11830.23.camel@nimitz>
	 <20081009134415.GA12135@elte.hu> <1223571036.11830.32.camel@nimitz>
	 <20081010153951.GD28977@elte.hu>  <48F30315.1070909@fr.ibm.com>
Content-Type: text/plain
Date: Mon, 13 Oct 2008 09:43:43 -0700
Message-Id: <1223916223.29877.14.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Cedric Le Goater <clg@fr.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, jeremy@goop.org, arnd@arndb.de, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Andrey Mirkin <major@openvz.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-10-13 at 10:13 +0200, Cedric Le Goater wrote:
> hmm, that's rather complex, because we have to take into account the 
> kernel stack, no ? This is what Andrey was trying to solve in his patchset 
> back in September :
> 
>         http://lkml.org/lkml/2008/9/3/96
> 
> the restart phase simulates a clone and switch_to to (not) restore the kernel 
> stack. right ? 

Do we ever have to worry about the kernel stack if we simply say that
tasks have to be *in* userspace when we checkpoint them.  If a task is
in an uninterruptable wait state, I'm not sure it's safe to checkpoint
it anyway.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
