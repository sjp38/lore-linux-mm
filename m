Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 728AC6B006E
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 02:32:18 -0500 (EST)
Received: by bke17 with SMTP id 17so4118250bke.14
        for <linux-mm@kvack.org>; Thu, 17 Nov 2011 23:32:15 -0800 (PST)
Message-ID: <4EC609FC.7000601@openvz.org>
Date: Fri, 18 Nov 2011 11:32:12 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: account reaped page cache on inode cache pruning
References: <20111116134713.8933.34389.stgit@zurg>	<20111117162322.1c3e3d05.akpm@linux-foundation.org>	<4EC5FE6A.3080003@openvz.org> <20111117225202.3535aba3.akpm@linux-foundation.org>
In-Reply-To: <20111117225202.3535aba3.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Chinner <david@fromorbit.com>

Andrew Morton wrote:
> On Fri, 18 Nov 2011 10:42:50 +0400 Konstantin Khlebnikov<khlebnikov@openvz.org>  wrote:
>
>> Do we really need separate on-stack reclaim_state structure with single field?
>> Maybe replace it with single long (or even unsigned int) .reclaimed_pages field on task_struct
>> and account reclaimed pages unconditionally.
>
> I don't think it matters a lot - it's either a temporary pointer on the
> stack or a permanent space consumption in the task_struct.

Yes, but currently task_struct has permanent pointer to reclaim_state =)

>
> The way thing are at present we can easily add new fields if needed.  I
> don't think we've ever done that though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
