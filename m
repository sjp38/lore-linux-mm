Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id AEE0D6B0083
	for <linux-mm@kvack.org>; Tue, 22 May 2012 13:27:17 -0400 (EDT)
Date: Tue, 22 May 2012 12:27:14 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: 3.4-rc7 numa_policy slab poison.
In-Reply-To: <20120521210959.GF12123@redhat.com>
Message-ID: <alpine.DEB.2.00.1205221226330.21828@router.home>
References: <20120517213120.GA12329@redhat.com> <20120518185851.GA5728@redhat.com> <20120521154709.GA8697@redhat.com> <CA+55aFyqMJ1X08kQwJ7snkYo6MxfVKqFJx7LXBkP_ug4LTCZ=Q@mail.gmail.com> <20120521200118.GA12123@redhat.com> <alpine.DEB.2.00.1205211510480.10940@router.home>
 <20120521202904.GB12123@redhat.com> <alpine.DEB.2.00.1205211535050.10940@router.home> <20120521203838.GD12123@redhat.com> <alpine.DEB.2.00.1205211544340.10940@router.home> <20120521210959.GF12123@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Stephen Wilson <wilsons@start.ca>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 21 May 2012, Dave Jones wrote:

> ok, added a --nocolors option now. Re-pull.
> I'll look at the dependancy problem next. Thanks for the feedback.

--monochrome you mean?

-m works for a part of the output but then the color hits again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
