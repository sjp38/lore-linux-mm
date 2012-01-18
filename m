Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 6397F6B004D
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 10:29:34 -0500 (EST)
Received: by obbta7 with SMTP id ta7so5601392obb.14
        for <linux-mm@kvack.org>; Wed, 18 Jan 2012 07:29:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F16D79C.2020402@redhat.com>
References: <1326788038-29141-1-git-send-email-minchan@kernel.org>
	<1326788038-29141-2-git-send-email-minchan@kernel.org>
	<CAOJsxLHGYmVNk7D9NyhRuqQDwquDuA7LtUtp-1huSn5F-GvtAg@mail.gmail.com>
	<4F15A34F.40808@redhat.com>
	<alpine.LFD.2.02.1201172044310.15303@tux.localdomain>
	<84FF21A720B0874AA94B46D76DB98269045596AE@008-AM1MPN1-003.mgdnok.nokia.com>
	<4F16D79C.2020402@redhat.com>
Date: Wed, 18 Jan 2012 17:29:33 +0200
Message-ID: <CAOJsxLHB=1t=kq2zASjAauFDrZQ5vROpjXs=XaSbmeMnzsaTLg@mail.gmail.com>
Subject: Re: [RFC 1/3] /dev/low_mem_notify
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: leonid.moiseichuk@nokia.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, rientjes@google.com, kosaki.motohiro@gmail.com, hannes@cmpxchg.org, mtosatti@redhat.com, akpm@linux-foundation.org, rhod@redhat.com, kosaki.motohiro@jp.fujitsu.com

On Wed, Jan 18, 2012 at 4:30 PM, Rik van Riel <riel@redhat.com> wrote:
> That seems like a horrible idea, because there is no guarantee that
> the kernel will continue to use NR_ACTIVE_ANON and NR_ACTIVE_FILE
> internally in the future.
>
> What is exported to userspace must be somewhat independent of the
> specifics of how the kernel implements things internally.

Exactly, that's what I'm also interested in.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
