Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 53D1C6B003D
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 03:38:25 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.1/8.13.1) with ESMTP id n327csbB015429
	for <linux-mm@kvack.org>; Thu, 2 Apr 2009 07:38:54 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n327csCt1462462
	for <linux-mm@kvack.org>; Thu, 2 Apr 2009 09:38:54 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n327cr6I018641
	for <linux-mm@kvack.org>; Thu, 2 Apr 2009 09:38:54 +0200
Date: Thu, 2 Apr 2009 09:38:52 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH] do_xip_mapping_read: fix length calculation
Message-ID: <20090402093852.30bbf3e9@skybase>
In-Reply-To: <20090401141700.f5ef3c08.akpm@linux-foundation.org>
References: <20090331153223.74b177bd@skybase>
	<20090401141700.f5ef3c08.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cotte@de.ibm.com, npiggin@suse.de, jaredeh@gmail.com
List-ID: <linux-mm.kvack.org>

On Wed, 1 Apr 2009 14:17:00 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 31 Mar 2009 15:32:23 +0200
> Martin Schwidefsky <schwidefsky@de.ibm.com> wrote:
>
> Please get into the habit of adding Cc: <stable@kernel.org> to the
> changelogs?

Ok, I've made me a sticky note and attached it to my monitor. Perhaps
that will help me to remember .. 

> I believe I personally am pretty good at picking up stable things, but
> other patch-mergers are quite unreliable.  We all need as much help as
> we can get on this, because things are falling through cracks.

Ok, makes sense. Better safe than sorry.
 
> > With this bug fix the commit 0e4a9b59282914fe057ab17027f55123964bc2e2
> > "ext2/xip: refuse to change xip flag during remount with busy inodes"
> > can be removed again.
> 
> OK, please send a standalone patch to do this at an appropriate time. 
> I guess that this second patch won't be needed in -stable.
 
The revert should be done either with the bug fix or after the bug fix
hit mainline. Guess I just create the patch and send it.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
