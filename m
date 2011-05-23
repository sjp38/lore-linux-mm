Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B844E6B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 15:13:56 -0400 (EDT)
Received: from mail-ew0-f41.google.com (mail-ew0-f41.google.com [209.85.215.41])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p4NJDq0w006025
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Mon, 23 May 2011 12:13:54 -0700
Received: by ewy9 with SMTP id 9so2818045ewy.14
        for <linux-mm@kvack.org>; Mon, 23 May 2011 12:13:49 -0700 (PDT)
MIME-Version: 1.0
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 23 May 2011 12:13:29 -0700
Message-ID: <BANLkTi=PLuZhx1=rCfOtg=aOTuC1UbuPYg@mail.gmail.com>
Subject: (Short?) merge window reminder
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, DRI <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Greg KH <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>

So I've been busily merging stuff, and just wanted to send out a quick
reminder that I warned people in the 39 announcement that this might
be a slightly shorter merge window than usual, so that I can avoid
having to make the -rc1 release from Japan using my slow laptop (doing
"allyesconfig" builds on that thing really isn't in the cards, and I
like to do those to verify things - even if we've already had a few
cases where arch include differences made it less than effective in
finding problems).

And judging by the merge window so far, that early close (probably
Sunday - I'll be on airplanes next Monday) looks rather likely. I
already seem to have a fairly sizable portion of linux-next in my
tree, and there haven't been any huge upsets.

So anybody who was planning a last-minute "please pull" - this is a
heads-up. Don't do it, you might miss the window entirely.

Did I miss any major development mailing lists with stuff pending?

                       Linus

PS. The voices in my head also tell me that the numbers are getting
too big. I may just call the thing 2.8.0. And I almost guarantee that
this PS is going to result in more discussion than the rest, but when
the voices tell me to do things, I listen.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
