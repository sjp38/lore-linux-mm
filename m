Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 8A3796B007E
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 11:48:44 -0500 (EST)
Received: by pbcup15 with SMTP id up15so1971185pbc.14
        for <linux-mm@kvack.org>; Thu, 08 Mar 2012 08:48:43 -0800 (PST)
Date: Fri, 9 Mar 2012 00:54:03 +0800
From: Zheng Liu <gnehzuil.liu@gmail.com>
Subject: Re: Control page reclaim granularity
Message-ID: <20120308165403.GA10005@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120308093514.GA28856@barrios>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com

Hi Minchan,

Sorry, I forgot to say that I don't subscribe linux-mm and linux-kernel
mailing list.  So please Cc me.

IMHO, maybe we should re-think about how does user use mmap(2).  I
describe the cases I known in our product system.  They can be
categorized into two cases.  One is mmaped all data files into memory
and sometime it uses write(2) to append some data, and another uses
mmap(2)/munmap(2) and read(2)/write(2) to manipulate the files.  In the
second case,  the application wants to keep mmaped page into memory and
let file pages to be reclaimed firstly.  So, IMO, when application uses
mmap(2) to manipulate files, it is possible to imply that it wants keep
these mmaped pages into memory and do not be reclaimed.  At least these
pages do not be reclaimed early than file pages.  I think that maybe we
can recover that routine and provide a sysctl parameter to let the user
to set this ratio between mmaped pages and file pages.

Regards,
Zheng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
