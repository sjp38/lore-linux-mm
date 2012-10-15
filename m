Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id A88AE6B00AA
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 10:41:49 -0400 (EDT)
Received: from mail-ea0-f169.google.com ([209.85.215.169])
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.71)
	(envelope-from <ming.lei@canonical.com>)
	id 1TNlrY-000742-Hz
	for linux-mm@kvack.org; Mon, 15 Oct 2012 14:41:48 +0000
Received: by mail-ea0-f169.google.com with SMTP id k11so1272922eaa.14
        for <linux-mm@kvack.org>; Mon, 15 Oct 2012 07:41:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.44L0.1210151029350.1702-100000@iolanthe.rowland.org>
References: <1350278059-14904-2-git-send-email-ming.lei@canonical.com>
	<Pine.LNX.4.44L0.1210151029350.1702-100000@iolanthe.rowland.org>
Date: Mon, 15 Oct 2012 22:41:48 +0800
Message-ID: <CACVXFVM=nNEthvSOzoTnoZ-7uhLGGmZ8ULsPu0N0d8QegtHYew@mail.gmail.com>
Subject: Re: [RFC PATCH 1/3] mm: teach mm by current context info to not do
 I/O during memory allocation
From: Ming Lei <ming.lei@canonical.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alan Stern <stern@rowland.harvard.edu>
Cc: linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, Oliver Neukum <oneukum@suse.de>, Jiri Kosina <jiri.kosina@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-mm <linux-mm@kvack.org>

On Mon, Oct 15, 2012 at 10:33 PM, Alan Stern <stern@rowland.harvard.edu> wrote:
>
> Instead of allow/forbid, the API should be save/restore (like
> local_irq_save and local_irq_restore).  This makes nesting much easier.

Good point.

> Also, do we really the "p" argument?  This is not at all likely to be
> used with any task other than the current one.

Yes, only 'current' can be passed now. I keep it because no performance
effect with macro implementation. But that is not good since it may
cause misuse. Will remove the 'p' argument.

Thanks,
--
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
