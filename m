Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id ACF2D6B00E5
	for <linux-mm@kvack.org>; Tue,  6 Jan 2009 15:23:26 -0500 (EST)
Date: Tue, 6 Jan 2009 12:23:01 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC v12][PATCH 00/14] Kernel based checkpoint/restart
Message-Id: <20090106122301.db538734.akpm@linux-foundation.org>
In-Reply-To: <1231272328.23462.43.camel@nimitz>
References: <1230542187-10434-1-git-send-email-orenl@cs.columbia.edu>
	<1231272328.23462.43.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: orenl@cs.columbia.edu, torvalds@linux-foundation.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, tglx@linutronix.de, serue@us.ibm.com, mingo@elte.hu, hpa@zytor.com, viro@zeniv.linux.org.uk, mikew@google.com
List-ID: <linux-mm.kvack.org>

On Tue, 06 Jan 2009 12:05:28 -0800
Dave Hansen <dave@linux.vnet.ibm.com> wrote:

> On Mon, 2008-12-29 at 04:16 -0500, Oren Laadan wrote:
> > Checkpoint-restart (c/r): fixed issues in error path handling (comments
> > from Mike Waychison) and . Updated and tested against v2.6.28
> > 
> > We'd like to push these into -mm.
> 
> Hey Andrew, I think we've exhausted all the reviewers on this one, and
> all the comments have been addressed.  How about a spin in -mm?
> 

I'll take a look soonish.  Now is not a good time to be merging new
features into anything..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
