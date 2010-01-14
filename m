Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DBD0E6B0087
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 00:46:37 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0E5kZvg015533
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 14 Jan 2010 14:46:35 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D19B45DE5B
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 14:46:35 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CF18945DE4D
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 14:46:34 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A651B1DB8044
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 14:46:34 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AE3911DB803E
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 14:46:33 +0900 (JST)
Date: Thu, 14 Jan 2010 14:42:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/8] vfs: fix too big f_pos handling
Message-Id: <20100114144250.ebbe6601.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100114051308.GA14616@ZenIV.linux.org.uk>
References: <20100113140955.GA18593@localhost>
	<20100114051308.GA14616@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: "Wu, Fengguang" <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Jan 2010 05:13:08 +0000
Al Viro <viro@ZenIV.linux.org.uk> wrote:

> On Wed, Jan 13, 2010 at 10:09:56PM +0800, Wu, Fengguang wrote:
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Now, rw_verify_area() checsk f_pos is negative or not. And if
> > negative, returns -EINVAL.
> > 
> > But, some special files as /dev/(k)mem and /proc/<pid>/mem etc..
> > has negative offsets. And we can't do any access via read/write
> > to the file(device).
> > 
> > This patch introduce a flag S_VERYBIG and allow negative file
> > offsets.
> 
> Ehh...  FMODE_NEG_OFFSET in file->f_mode, perhaps?
> 
Any method is okay for me.
I was just not sure where I could modify without problem.
If modifing f_mode is allowed, I'll write new version.

Thank you for advice. 

I'm sorry that I don't have enough time this week. So, I'll try next week.
I think dropping this patch itself has no big influence to this patch set. 
(but debug will be harder ;)
Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
