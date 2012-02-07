Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 49CD86B13F0
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 23:13:57 -0500 (EST)
Received: by wgbdt12 with SMTP id dt12so5741851wgb.26
        for <linux-mm@kvack.org>; Mon, 06 Feb 2012 20:13:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CANAOKxs8j2T2b0tKssFX9NeC1wyMqjLMQmgmRwMs9qvokYcW2w@mail.gmail.com>
References: <CAG4AFWaXVEHP+YikRSyt8ky9XsiBnwQ3O94Bgc7-b7nYL_2PZQ@mail.gmail.com>
	<CANAOKxs8j2T2b0tKssFX9NeC1wyMqjLMQmgmRwMs9qvokYcW2w@mail.gmail.com>
Date: Mon, 6 Feb 2012 23:13:55 -0500
Message-ID: <CAG4AFWZGr8SQF0rV+iys04HWmQ5WEGvXNcSZ9qJ7Jj9+FRbjCg@mail.gmail.com>
Subject: Re: Strange finding about kernel samepage merging
From: Jidong Xiao <jidong.xiao@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Roth <mdroth@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, virtualization@lists.linux-foundation.org

On Mon, Feb 6, 2012 at 10:35 PM, Michael Roth <mdroth@linux.vnet.ibm.com> wrote:
> My guess is you end up with 2 copies of each page on the guest: the copy in
> the guest's page cache, and the copy in the buffer you allocated. From the
> perspective of the host this all looks like anonymous memory, so ksm merges
> the pages.

Yes, the result definitely shows that there two copies. But I don't
understand why there would be two copies. So whenever you allocate
memory in a guest OS, you will always create two copies of the same
memory?

An interesting thing is, if I replace the posix_memalign() function
with the malloc() function (See the original program, the commented
line.) there would be only one copy, i.e., no merging happens,
however, since I need to have some page-aligned memory, that's why I
use posix_memalign().

Regards
Jidong

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
