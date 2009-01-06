Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A84C46B00E5
	for <linux-mm@kvack.org>; Tue,  6 Jan 2009 15:05:54 -0500 (EST)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n06K4fHW008801
	for <linux-mm@kvack.org>; Tue, 6 Jan 2009 15:04:41 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n06K5qLA198134
	for <linux-mm@kvack.org>; Tue, 6 Jan 2009 15:05:52 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n06K5iX4015196
	for <linux-mm@kvack.org>; Tue, 6 Jan 2009 15:05:51 -0500
Subject: Re: [RFC v12][PATCH 00/14] Kernel based checkpoint/restart
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1230542187-10434-1-git-send-email-orenl@cs.columbia.edu>
References: <1230542187-10434-1-git-send-email-orenl@cs.columbia.edu>
Content-Type: text/plain
Date: Tue, 06 Jan 2009 12:05:28 -0800
Message-Id: <1231272328.23462.43.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Mike Waychison <mikew@google.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-12-29 at 04:16 -0500, Oren Laadan wrote:
> Checkpoint-restart (c/r): fixed issues in error path handling (comments
> from Mike Waychison) and . Updated and tested against v2.6.28
> 
> We'd like to push these into -mm.

Hey Andrew, I think we've exhausted all the reviewers on this one, and
all the comments have been addressed.  How about a spin in -mm?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
