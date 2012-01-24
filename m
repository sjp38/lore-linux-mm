Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id D30576B004F
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 11:25:59 -0500 (EST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC 1/3] /dev/low_mem_notify
Date: Tue, 24 Jan 2012 16:25:55 +0000
References: <1326788038-29141-1-git-send-email-minchan@kernel.org> <20120124154001.GB10990@amt.cnet> <1327420880.13624.24.camel@jaguar>
In-Reply-To: <1327420880.13624.24.camel@jaguar>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201201241625.55295.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, leonid.moiseichuk@nokia.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, rientjes@google.com, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Ronen Hod <rhod@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Tuesday 24 January 2012, Pekka Enberg wrote:
> On Tue, 2012-01-24 at 13:40 -0200, Marcelo Tosatti wrote:
> > What is the practical advantage of a syscall, again?
> 
> Why do you ask? The advantage for this particular case is not needing to
> add ioctls() for configuration and keeping the file read/write ABI
> simple.

The two are obviously equivalent and there is no reason to avoid
ioctl in general. However I agree that the syscall would be better
in this case, because that is what we tend to use for core kernel
functionality, while character devices tend to be used for I/O device
drivers that need stuff like enumeration and permission management.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
