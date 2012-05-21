Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id D00046B00ED
	for <linux-mm@kvack.org>; Mon, 21 May 2012 16:18:41 -0400 (EDT)
Date: Mon, 21 May 2012 15:18:38 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: 3.4-rc7 numa_policy slab poison.
In-Reply-To: <20120521200118.GA12123@redhat.com>
Message-ID: <alpine.DEB.2.00.1205211510480.10940@router.home>
References: <20120517213120.GA12329@redhat.com> <20120518185851.GA5728@redhat.com> <20120521154709.GA8697@redhat.com> <CA+55aFyqMJ1X08kQwJ7snkYo6MxfVKqFJx7LXBkP_ug4LTCZ=Q@mail.gmail.com> <20120521200118.GA12123@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Stephen Wilson <wilsons@start.ca>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 21 May 2012, Dave Jones wrote:

> On Mon, May 21, 2012 at 12:39:19PM -0700, Linus Torvalds wrote:
>
>  > But there's not a lot of recent stuff. The thing that jumps out is Mel
>  > Gorman's recent commit cc9a6c8776615 ("cpuset: mm: reduce large
>  > amounts of memory barrier related damage v3"), which has a whole new
>  > loop with that scary mpol_cond_put() usage. And there's we had
>  > problems with vma merging..
>  >
>  > Dave, how recent is this problem? Have you already tried older kernels?
>
> I tried bisecting, but couldn't find a 'good' kernel.
> I Went back as far as 3.0, before that I kept running into compile failures.
> Newer gcc/binutils really seems to dislike 2.6.x now.

Well binary distro kernels are available that allow easy testing. Will try
with what I got here. I have reproduced it with 3.4 so far.

Its always an mput on a freed memory policy. Slub recovery keeps my system
up at least. I just get the errors dumped to dmesg.

Is there any way to get the trinity tool to stop when the kernel writes
errors to dmesg? That way I could see the parameters passed to mbind?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
