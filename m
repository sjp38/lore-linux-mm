Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E57F98D003A
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 16:02:01 -0500 (EST)
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Date: Thu, 10 Mar 2011 22:00:40 +0100
From: Mordae <mordae@anilinux.org>
In-Reply-To: <alpine.DEB.2.00.1103101309090.2161@router.home>
References: <056c7b49e7540a910b8a4f664415e638@anilinux.org> <alpine.DEB.2.00.1103101309090.2161@router.home>
Message-ID: <faf1c53253ae791c39448de707b96c15@anilinux.org>
Subject: Re: COW userspace memory mapping question
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org

On Thu, 10 Mar 2011 13:13:02 -0600 (CST), Christoph Lameter <cl@linux.com>
wrote:
> Its probably more an issue of us understanding what you want.

Okay. I've posted the message from within the CET. It was
approximately 1 am and I am not a native speaker. So, once again
sorry and thanks a lot for your help. :-)

Now to the question.

> Ok let say you have a memory range in the address space from which you
> want to take a snapshot. How is that snapshot data visible? To another
> process? Via a file?

As I understand that, before a process forks, all of it's private memory
pages are somehow magically marked. When a process with access to such
page attempts to modify it, the page is duplicated and the copy replaces
the shared page for this process. Then the actual modification is
carried on.

What I am interested in is a hypothetical system call

  void *mcopy(void *dst, void *src, size_t len, int flags);

which would make src pages marked in the same way and mapped *also* to
the dst. Afterwards, any modification to either mapping would not
influence the other.

Now, is there something like that?

Best regards,
    Jan Dvorak

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
