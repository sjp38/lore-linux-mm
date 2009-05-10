Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D91C56B003D
	for <linux-mm@kvack.org>; Sun, 10 May 2009 01:33:15 -0400 (EDT)
Date: Sat, 9 May 2009 22:26:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/8] proc: export more page flags in /proc/kpageflags
Message-Id: <20090509222612.887b96e3.akpm@linux-foundation.org>
In-Reply-To: <20090509104409.GB16138@elte.hu>
References: <20090508105320.316173813@intel.com>
	<20090508111031.020574236@intel.com>
	<20090508114742.GB17129@elte.hu>
	<20090508132452.bafa287a.akpm@linux-foundation.org>
	<20090509104409.GB16138@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: fengguang.wu@intel.com, fweisbec@gmail.com, rostedt@goodmis.org, a.p.zijlstra@chello.nl, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, andi@firstfloor.org, mpm@selenic.com, adobriyan@gmail.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 9 May 2009 12:44:09 +0200 Ingo Molnar <mingo@elte.hu> wrote:

> And because it was so crappy to be in /proc we are now also
> treating it as a hard ABI, not as a debugfs interface - for that
> single app that is using it. 

We'd probably make better progress here were someone to explain what
pagemap actually is.


pagemap is a userspace interface via which application developers
(including embedded) can analyse, understand and optimise their use of
memory.

It is not debugging feature at all, let alone a kernel debugging
feature.  For this reason it is not appropriate that its interfaces be
presented in debugfs.

Furthermore the main control file for pagemap is in
/proc/<pid>/pagemap.  pagemap _cannot_ be put in debugfs because
debugfs doesn't maintain the per-process subdirectories in which to
place it.  /proc/<pid>/ is exactly the place where the pagemap file
should appear.

Yes, we could place pagemap's two auxiliary files into debugfs but it
would be rather stupid to split the feature's control files across two
pseudo filesystems, one of which may not even exist.  Plus pagemap is
not a kernel debugging feature.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
