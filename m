Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 9C8DD6B00F5
	for <linux-mm@kvack.org>; Mon, 21 May 2012 16:30:19 -0400 (EDT)
Date: Mon, 21 May 2012 16:30:14 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: 3.4-rc7 numa_policy slab poison.
Message-ID: <20120521203014.GC12123@redhat.com>
References: <20120517213120.GA12329@redhat.com>
 <20120518185851.GA5728@redhat.com>
 <20120521154709.GA8697@redhat.com>
 <CA+55aFyqMJ1X08kQwJ7snkYo6MxfVKqFJx7LXBkP_ug4LTCZ=Q@mail.gmail.com>
 <20120521200118.GA12123@redhat.com>
 <alpine.DEB.2.00.1205211510480.10940@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1205211510480.10940@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Stephen Wilson <wilsons@start.ca>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>

On Mon, May 21, 2012 at 03:18:38PM -0500, Christoph Lameter wrote:

 > Its always an mput on a freed memory policy. Slub recovery keeps my system
 > up at least. I just get the errors dumped to dmesg.
 > 
 > Is there any way to get the trinity tool to stop when the kernel writes
 > errors to dmesg? That way I could see the parameters passed to mbind?

another way might be to remove the -q argument, and use -p which inserts
a pause() after each syscall.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
