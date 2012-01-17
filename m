Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 1695E6B00B9
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 08:58:50 -0500 (EST)
Received: by vbbfa15 with SMTP id fa15so2115213vbb.14
        for <linux-mm@kvack.org>; Tue, 17 Jan 2012 05:58:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <84FF21A720B0874AA94B46D76DB9826904559397@008-AM1MPN1-003.mgdnok.nokia.com>
References: <cover.1326803859.git.leonid.moiseichuk@nokia.com>
	<5b429d6c4d0a3ad06ec01193eab7edc98a03e0de.1326803859.git.leonid.moiseichuk@nokia.com>
	<CAOJsxLFCbF8azY48_SHhYQ0oRDrf2-rEvGMKHBne2Znpj0XL4g@mail.gmail.com>
	<84FF21A720B0874AA94B46D76DB9826904559397@008-AM1MPN1-003.mgdnok.nokia.com>
Date: Tue, 17 Jan 2012 15:58:48 +0200
Message-ID: <CAOJsxLEtuzEYVUtukrA1JeJnuOJ6OsOHOj=j2gs=-0NHYVPzLQ@mail.gmail.com>
Subject: Re: [PATCH v2 2/2] Memory notification pseudo-device module
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: leonid.moiseichuk@nokia.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, kamezawa.hiroyu@jp.fujitsu.com, emunson@mgebm.net, aarcange@redhat.com, riel@redhat.com, mel@csn.ul.ie, rientjes@google.com, dima@android.com, gregkh@suse.de, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

On Tue, Jan 17, 2012 at 3:45 PM,  <leonid.moiseichuk@nokia.com> wrote:
> 3. maybe someone needs similar solution, keep it internally = kill it. Now
> module looks pretty simple for me and maintainable. Plus one small issue
> fixed for swapinfo()

If you're serious about making this a generic thing, it must live in
mm/mem_notify.c. No ifs or buts about it.

I'm also not completely convinced we need to put memnotify policy in
the kernel. Why can't we extend Minchan's patch to report the relevant
numbers and let the userspace figure out when pressure is above some
interesting threshold?

                                Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
