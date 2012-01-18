Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id DB5E06B004D
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 09:31:32 -0500 (EST)
Message-ID: <4F16D79C.2020402@redhat.com>
Date: Wed, 18 Jan 2012 09:30:52 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/3] /dev/low_mem_notify
References: <1326788038-29141-1-git-send-email-minchan@kernel.org> <1326788038-29141-2-git-send-email-minchan@kernel.org> <CAOJsxLHGYmVNk7D9NyhRuqQDwquDuA7LtUtp-1huSn5F-GvtAg@mail.gmail.com> <4F15A34F.40808@redhat.com> <alpine.LFD.2.02.1201172044310.15303@tux.localdomain> <84FF21A720B0874AA94B46D76DB98269045596AE@008-AM1MPN1-003.mgdnok.nokia.com>
In-Reply-To: <84FF21A720B0874AA94B46D76DB98269045596AE@008-AM1MPN1-003.mgdnok.nokia.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: leonid.moiseichuk@nokia.com
Cc: penberg@kernel.org, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, rientjes@google.com, kosaki.motohiro@gmail.com, hannes@cmpxchg.org, mtosatti@redhat.com, akpm@linux-foundation.org, rhod@redhat.com, kosaki.motohiro@jp.fujitsu.com

On 01/18/2012 04:06 AM, leonid.moiseichuk@nokia.com wrote:

> Would be possible to use for threshold pointed value(s) e.g. according to enum zone_state_item, because kinds of memory to track could be different?
> E.g. to tracking paging activity NR_ACTIVE_ANON and NR_ACTIVE_FILE could be interesting, not only free.

That seems like a horrible idea, because there is no guarantee that
the kernel will continue to use NR_ACTIVE_ANON and NR_ACTIVE_FILE
internally in the future.

What is exported to userspace must be somewhat independent of the
specifics of how the kernel implements things internally.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
