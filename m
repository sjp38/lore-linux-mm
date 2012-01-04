Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 561E06B004F
	for <linux-mm@kvack.org>; Wed,  4 Jan 2012 15:18:41 -0500 (EST)
Message-ID: <4F04B3F0.6080103@redhat.com>
Date: Wed, 04 Jan 2012 15:17:52 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3.2.0-rc1 0/3] Used Memory Meter pseudo-device and related
 changes in MM
References: <cover.1325696593.git.leonid.moiseichuk@nokia.com> <20120104195612.GB19181@suse.de>
In-Reply-To: <20120104195612.GB19181@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@suse.de>
Cc: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, kamezawa.hiroyu@jp.fujitsu.com, emunson@mgebm.net, penberg@kernel.org, aarcange@redhat.com, mel@csn.ul.ie, rientjes@google.com, dima@android.com, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com, Minchan Kim <minchan@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>

On 01/04/2012 02:56 PM, Greg KH wrote:

> How does this compare with the lowmemorykiller.c driver from the android
> developers that is currently in the linux-next tree?

Also, the low memory notification that Kosaki-san has worked on,
and which Minchan is looking at now.

We seem to have many mechanisms under development, all aimed at
similar goals. I believe it would be good to agree on one mechanism
that could solve multiple of these goals at once, instead of sticking
a handful of different partial solutions in the kernel...

Exactly what is the problem you are trying to solve?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
