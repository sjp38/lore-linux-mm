Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id CDC716B0083
	for <linux-mm@kvack.org>; Tue, 22 May 2012 11:43:17 -0400 (EDT)
Received: by wibhj6 with SMTP id hj6so3097963wib.8
        for <linux-mm@kvack.org>; Tue, 22 May 2012 08:43:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120522115910.GA3353@suse.de>
References: <20120517213120.GA12329@redhat.com> <20120518185851.GA5728@redhat.com>
 <20120521154709.GA8697@redhat.com> <CA+55aFyqMJ1X08kQwJ7snkYo6MxfVKqFJx7LXBkP_ug4LTCZ=Q@mail.gmail.com>
 <20120521200118.GA12123@redhat.com> <20120522115910.GA3353@suse.de>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 22 May 2012 08:42:55 -0700
Message-ID: <CA+55aFwdyt310Mcsk==58Qa-sZD05A=M+R06xwOisbg2gex=RA@mail.gmail.com>
Subject: Re: 3.4-rc7 numa_policy slab poison.
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Stephen Wilson <wilsons@start.ca>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, May 22, 2012 at 4:59 AM, Mel Gorman <mgorman@suse.de> wrote:
>
> This bug is really old as it triggers as far back as 2.6.32.58. I don't
> know why yet.

Would somebody humor me, and try it without the MPOL_F_SHARED games?
The whole reference counting in the presense of setting and clearing
that bit looks totally crazy. I really cannot see how it could ever
work.

I realize that it avoids a copy, but I really don't see how the
refcounting is supposed to work for it..

                       Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
