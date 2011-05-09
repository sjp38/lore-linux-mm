Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1E01F6B0023
	for <linux-mm@kvack.org>; Mon,  9 May 2011 18:29:19 -0400 (EDT)
Date: Mon, 9 May 2011 15:28:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/4] VM/RMAP: Add infrastructure for batching the rmap
 chain locking
Message-Id: <20110509152841.ec957d23.akpm@linux-foundation.org>
In-Reply-To: <4DC86947.30607@linux.intel.com>
References: <1304623972-9159-1-git-send-email-andi@firstfloor.org>
	<1304623972-9159-2-git-send-email-andi@firstfloor.org>
	<20110509144324.8e79654a.akpm@linux-foundation.org>
	<4DC86947.30607@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, tim.c.chen@linux.intel.com, torvalds@linux-foundation.org, lwoodman@redhat.com, mel@csn.ul.ie

On Mon, 09 May 2011 15:23:03 -0700
Andi Kleen <ak@linux.intel.com> wrote:

> > After fixing that and doing an allnoconfig x86_64 build, the patchset
> > takes rmap.o's .text from 6167 bytes to 6551.  This is likely to be a
> > regression for uniprocessor machines.  What can we do about this?
> >
> 
> Regression in what way?

It makes the code larger and probably slower, for no gain?

> I guess I can move some of the functions out of 
> line.

I don't know how much that will help.  Perhaps a wholesale refactoring
and making it all SMP-only will be justified.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
