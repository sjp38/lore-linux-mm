Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 395AF6B024D
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 01:41:22 -0400 (EDT)
Date: Mon, 26 Jul 2010 15:41:11 +1000
From: Nick Piggin <npiggin@kernel.dk>
Subject: Re: VFS scalability git tree
Message-ID: <20100726054111.GA2963@amd>
References: <20100722190100.GA22269@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100722190100.GA22269@amd>
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Frank Mayhar <fmayhar@google.com>, John Stultz <johnstul@us.ibm.com>, Dave Chinner <david@fromorbit.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michael Neuling <mikey@neuling.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 23, 2010 at 05:01:00AM +1000, Nick Piggin wrote:
> I'm pleased to announce I have a git tree up of my vfs scalability work.
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/npiggin/linux-npiggin.git
> http://git.kernel.org/?p=linux/kernel/git/npiggin/linux-npiggin.git

Pushed several fixes and improvements
o XFS bugs fixed by Dave
o dentry and inode stats bugs noticed by Dave
o vmscan shrinker bugs fixed by KOSAKI san
o compile bugs noticed by John
o a few attempts to improve powerpc performance (eg. reducing smp_rmb())
o scalability improvments for rename_lock


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
