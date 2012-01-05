Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 83DE86B004D
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 10:42:26 -0500 (EST)
Date: Thu, 5 Jan 2012 06:57:53 -0800
From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH 3.2.0-rc1 0/3] Used Memory Meter pseudo-device and
 related changes in MM
Message-ID: <20120105145753.GA3937@suse.de>
References: <cover.1325696593.git.leonid.moiseichuk@nokia.com>
 <20120104195612.GB19181@suse.de>
 <84FF21A720B0874AA94B46D76DB98269045542B5@008-AM1MPN1-003.mgdnok.nokia.com>
 <CAOJsxLEdTMB6JtYViRJq5gZ4_w5aaV18S3q-1rOXGzaMtmiW6A@mail.gmail.com>
 <84FF21A720B0874AA94B46D76DB9826904554391@008-AM1MPN1-003.mgdnok.nokia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84FF21A720B0874AA94B46D76DB9826904554391@008-AM1MPN1-003.mgdnok.nokia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: leonid.moiseichuk@nokia.com
Cc: penberg@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, kamezawa.hiroyu@jp.fujitsu.com, emunson@mgebm.net, aarcange@redhat.com, riel@redhat.com, mel@csn.ul.ie, rientjes@google.com, dima@android.com, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

A: No.
Q: Should I include quotations after my reply?

http://daringfireball.net/2007/07/on_top

On Thu, Jan 05, 2012 at 01:02:23PM +0000, leonid.moiseichuk@nokia.com wrote:
> Well, mm/notify.c seems a bit global for me. At the first step I
> handle inputs from Greg and try to find less destructive approach to
> allocation tracking rather than page_alloc.

No, please listen to what people, including me, are saying, otherwise
your code will be totally ignored.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
