Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 6D84C6B004F
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 11:01:24 -0500 (EST)
Subject: Re: [RFC 1/3] /dev/low_mem_notify
From: Pekka Enberg <penberg@kernel.org>
In-Reply-To: <20120124154001.GB10990@amt.cnet>
References: <1326788038-29141-1-git-send-email-minchan@kernel.org>
	 <1326788038-29141-2-git-send-email-minchan@kernel.org>
	 <CAOJsxLHGYmVNk7D9NyhRuqQDwquDuA7LtUtp-1huSn5F-GvtAg@mail.gmail.com>
	 <4F15A34F.40808@redhat.com>
	 <alpine.LFD.2.02.1201172044310.15303@tux.localdomain>
	 <20120124154001.GB10990@amt.cnet>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Tue, 24 Jan 2012 18:01:20 +0200
Message-ID: <1327420880.13624.24.camel@jaguar>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, leonid.moiseichuk@nokia.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, rientjes@google.com, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Ronen Hod <rhod@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Tue, 2012-01-24 at 13:40 -0200, Marcelo Tosatti wrote:
> What is the practical advantage of a syscall, again?

Why do you ask? The advantage for this particular case is not needing to
add ioctls() for configuration and keeping the file read/write ABI
simple.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
