Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id C95376B00E9
	for <linux-mm@kvack.org>; Mon, 21 May 2012 17:19:45 -0400 (EDT)
Date: Mon, 21 May 2012 15:41:30 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: 3.4-rc7 numa_policy slab poison.
In-Reply-To: <20120521203014.GC12123@redhat.com>
Message-ID: <alpine.DEB.2.00.1205211540010.10940@router.home>
References: <20120517213120.GA12329@redhat.com> <20120518185851.GA5728@redhat.com> <20120521154709.GA8697@redhat.com> <CA+55aFyqMJ1X08kQwJ7snkYo6MxfVKqFJx7LXBkP_ug4LTCZ=Q@mail.gmail.com> <20120521200118.GA12123@redhat.com> <alpine.DEB.2.00.1205211510480.10940@router.home>
 <20120521203014.GC12123@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Stephen Wilson <wilsons@start.ca>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 21 May 2012, Dave Jones wrote:

> On Mon, May 21, 2012 at 03:18:38PM -0500, Christoph Lameter wrote:
>
>  > Its always an mput on a freed memory policy. Slub recovery keeps my system
>  > up at least. I just get the errors dumped to dmesg.
>  >
>  > Is there any way to get the trinity tool to stop when the kernel writes
>  > errors to dmesg? That way I could see the parameters passed to mbind?
>
> another way might be to remove the -q argument, and use -p which inserts
> a pause() after each syscall.

Without -q it does not trigger anymore. Output is slow so I guess there is
some race condition that does not occur when things occur with less
frequency.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
