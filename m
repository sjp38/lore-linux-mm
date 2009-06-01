Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C0C985F0003
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 12:01:47 -0400 (EDT)
Date: Mon, 1 Jun 2009 12:35:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Warn if we run out of swap space
Message-Id: <20090601123503.2337a79b.akpm@linux-foundation.org>
In-Reply-To: <4A23FF89.2060603@redhat.com>
References: <alpine.DEB.1.10.0905221454460.7673@qirst.com>
	<4A23FF89.2060603@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: cl@linux-foundation.org, linux-mm@kvack.org, pavel@ucw.cz, dave@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, 01 Jun 2009 19:19:21 +0300
Avi Kivity <avi@redhat.com> wrote:

> Christoph Lameter wrote:
> > Subject: Warn if we run out of swap space
> >
> > Running out of swap space means that the evicton of anonymous pages may no longer
> > be possible which can lead to OOM conditions.
> >
> > Print a warning when swap space first becomes exhausted.
> >   
> 
> We really should have a machine readable channel for this sort of 
> information, so it can be plumbed to a userspace notification bubble the 
> user can ignore.

That could just be printk().  It's a question of a) how to tell
userspace which bits to pay attention to and maybe b) adding some
more structure to the text.

Perhaps careful use of faciliy levels would suffice for a), but I
expect that some new tagging scheme would be more practical.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
