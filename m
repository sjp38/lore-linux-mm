Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 983126B0062
	for <linux-mm@kvack.org>; Wed,  4 Jan 2012 15:42:59 -0500 (EST)
Received: by obcwo8 with SMTP id wo8so18668215obc.14
        for <linux-mm@kvack.org>; Wed, 04 Jan 2012 12:42:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F04B3F0.6080103@redhat.com>
References: <cover.1325696593.git.leonid.moiseichuk@nokia.com>
	<20120104195612.GB19181@suse.de>
	<4F04B3F0.6080103@redhat.com>
Date: Wed, 4 Jan 2012 22:42:58 +0200
Message-ID: <CAOJsxLH8s5cjUSdpBpLNDvtNaJjnhBwNKOMXZPzUD=XDivr7Rg@mail.gmail.com>
Subject: Re: [PATCH 3.2.0-rc1 0/3] Used Memory Meter pseudo-device and related
 changes in MM
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Greg KH <gregkh@suse.de>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, kamezawa.hiroyu@jp.fujitsu.com, emunson@mgebm.net, aarcange@redhat.com, mel@csn.ul.ie, rientjes@google.com, dima@android.com, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com, Minchan Kim <minchan@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>

On Wed, Jan 4, 2012 at 10:17 PM, Rik van Riel <riel@redhat.com> wrote:
> Also, the low memory notification that Kosaki-san has worked on,
> and which Minchan is looking at now.
>
> We seem to have many mechanisms under development, all aimed at
> similar goals. I believe it would be good to agree on one mechanism
> that could solve multiple of these goals at once, instead of sticking
> a handful of different partial solutions in the kernel...

And even if people want to support multiple ABIs and fight it out to
see which one wins, we should factor out the generic parts and put
them under mm/*.c and not hide them in random modules.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
