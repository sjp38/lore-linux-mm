Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 031F26B0093
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 04:45:08 -0500 (EST)
Received: by vbbfa15 with SMTP id fa15so1921390vbb.14
        for <linux-mm@kvack.org>; Tue, 17 Jan 2012 01:45:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1326788038-29141-2-git-send-email-minchan@kernel.org>
References: <1326788038-29141-1-git-send-email-minchan@kernel.org>
	<1326788038-29141-2-git-send-email-minchan@kernel.org>
Date: Tue, 17 Jan 2012 11:45:06 +0200
Message-ID: <CAOJsxLFdm_vLcuWzzcC==JTpVERuf4XNUOqvRyLt=Q0ixqmx7A@mail.gmail.com>
Subject: Re: [RFC 1/3] /dev/low_mem_notify
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, leonid.moiseichuk@nokia.com, kamezawa.hiroyu@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, mel@csn.ul.ie, rientjes@google.com, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Marcelo Tosatti <mtosatti@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ronen Hod <rhod@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Tue, Jan 17, 2012 at 10:13 AM, Minchan Kim <minchan@kernel.org> wrote:
> This patch makes new device file "/dev/low_mem_notify".
> If application polls it, it can receive event when system
> memory pressure happens.
>
> This patch is based on KOSAKI and Marcelo's long time ago work.
> http://lwn.net/Articles/268732/

I'm not loving the ABI. Alternative solutions:

  - SIGDANGER + signalfd() for poll

  - sys_eventfd()

  - sys_mem_notify_open() similar to sys_perf_event_open()

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
