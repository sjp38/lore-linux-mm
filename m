Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 259676B004D
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 07:40:51 -0500 (EST)
Received: by obcwo8 with SMTP id wo8so687635obc.14
        for <linux-mm@kvack.org>; Thu, 05 Jan 2012 04:40:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <84FF21A720B0874AA94B46D76DB98269045542B5@008-AM1MPN1-003.mgdnok.nokia.com>
References: <cover.1325696593.git.leonid.moiseichuk@nokia.com>
	<20120104195612.GB19181@suse.de>
	<84FF21A720B0874AA94B46D76DB98269045542B5@008-AM1MPN1-003.mgdnok.nokia.com>
Date: Thu, 5 Jan 2012 14:40:49 +0200
Message-ID: <CAOJsxLEdTMB6JtYViRJq5gZ4_w5aaV18S3q-1rOXGzaMtmiW6A@mail.gmail.com>
Subject: Re: [PATCH 3.2.0-rc1 0/3] Used Memory Meter pseudo-device and related
 changes in MM
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: leonid.moiseichuk@nokia.com
Cc: gregkh@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, kamezawa.hiroyu@jp.fujitsu.com, emunson@mgebm.net, aarcange@redhat.com, riel@redhat.com, mel@csn.ul.ie, rientjes@google.com, dima@android.com, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

On Thu, Jan 5, 2012 at 1:47 PM,  <leonid.moiseichuk@nokia.com> wrote:
> As I understand AOOM it wait until situation is reached bad conditions which
> required memory reclaiming, selects application according to free memory and
> oom_adj level and kills it.  So no intermediate levels could be checked (e.g.
> 75% usage),  nothing could be done in user-space to prevent killing, no
> notification for case when memory becomes OK.
>
> What I try to do is to get notification in any application that memory
> becomes low, and do something about it like stop processing data, close
> unused pages or correctly shuts applications, daemons.  Application(s) might
> have necessity to install several notification levels, so reaction could be
> adjusted based on current utilization level per each application, not
> globally.

Sure. However, from VM point of view, both have the exact same
functionality: detect when we reach low memory condition (for some
configurable threshold) and notify userspace or kernel subsystem about
it.

That's the part I'd like to see implemented in mm/notify.c or similar.
I really don't care what Android or any other folks use it for exactly
as long as the generic code is light-weight, clean, and we can
reasonably assume that distros can actually enable it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
