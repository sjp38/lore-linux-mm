Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 8282A6B00FA
	for <linux-mm@kvack.org>; Mon, 21 May 2012 16:36:42 -0400 (EDT)
Date: Mon, 21 May 2012 15:36:39 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: 3.4-rc7 numa_policy slab poison.
In-Reply-To: <20120521202904.GB12123@redhat.com>
Message-ID: <alpine.DEB.2.00.1205211535050.10940@router.home>
References: <20120517213120.GA12329@redhat.com> <20120518185851.GA5728@redhat.com> <20120521154709.GA8697@redhat.com> <CA+55aFyqMJ1X08kQwJ7snkYo6MxfVKqFJx7LXBkP_ug4LTCZ=Q@mail.gmail.com> <20120521200118.GA12123@redhat.com> <alpine.DEB.2.00.1205211510480.10940@router.home>
 <20120521202904.GB12123@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Stephen Wilson <wilsons@start.ca>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 21 May 2012, Dave Jones wrote:

> It does create log files in the current dir with the parameters used.
> You should be able to grep for the pid that caused the actual oops.

Ugghh. It screws up the colors on my screeen. Lightgrey on white. Is there
any way to get these horrible escape sequences cleared out? If I use
"less" to view the output then there are just the escape sequences
visible.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
