Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 419FF6B016A
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 06:16:40 -0400 (EDT)
Date: Thu, 1 Sep 2011 11:16:23 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Kernel panic in 2.6.35.12 kernel
Message-ID: <20110901101623.GB29729@n2100.arm.linux.org.uk>
References: <CAJ8eaTyeQj5_EAsCFDMmDs3faiVptuccmq3VJLjG-QnYG038=A@mail.gmail.com> <CAJ8eaTw=dKUNE8h-HD7RWxXHcTEuxJH4AfcOO44RSF7QdC5arQ@mail.gmail.com> <CAJ8eaTyaiFzAnKB-P9EJT5UxxmpgTpw=Yk_Ee8qJUVKFjfHtKQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJ8eaTyaiFzAnKB-P9EJT5UxxmpgTpw=Yk_Ee8qJUVKFjfHtKQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: naveen yadav <yad.naveen@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm <linux-mm@kvack.org>

On Thu, Aug 25, 2011 at 12:08:12PM +0530, naveen yadav wrote:
> adding to mm mailing list

I think rather than just adding a mailing list to a message containing
almost no useful content, you may do better to start a new thread
including the linux-mm mailing list, describing the problem that you're
seeing, the kernel messages plus the test program all in a single
message.

I don't think the problem you're reporting is ARM specific - to me it
looks like something is holding on to processes pages after they've
been killed, and only giving them back after the OOM killer has killed
off the last killable task.  That's certainly what the "xxx free pages"
values hint at.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
