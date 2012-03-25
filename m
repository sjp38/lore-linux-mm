Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 1249A6B0092
	for <linux-mm@kvack.org>; Sun, 25 Mar 2012 15:39:32 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so6203800pbc.14
        for <linux-mm@kvack.org>; Sun, 25 Mar 2012 12:39:31 -0700 (PDT)
Date: Sun, 25 Mar 2012 12:39:08 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Possible Swapfile bug
In-Reply-To: <4F6D45F2.9080201@storytotell.org>
Message-ID: <alpine.LSU.2.00.1203251217160.1984@eggly.anvils>
References: <4F6B5236.20805@storytotell.org> <20120322124635.85fd4673.akpm@linux-foundation.org> <4F6BC8A8.6080202@storytotell.org> <alpine.LSU.2.00.1203230440360.31745@eggly.anvils> <4F6D45F2.9080201@storytotell.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Mattax <jmattax@storytotell.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, cesarb@cesarb.net, penberg@kernel.org, linux-mm@kvack.org

On Fri, 23 Mar 2012, Jason Mattax wrote:
> On 03/23/2012 06:05 AM, Hugh Dickins wrote:
> > 
> > I'm not surprised that you saw no problem on 2.6.32.27, but I am
> > very surprised that you see the problem on 2.6.33.1 - I'm wondering
> > if that's a typo for something else, or a distro kernel which actually
> > contains changes from later releases?

> I can't say why I saw it then, but I got the 2.6.33.1 kernel off of
> http://www.kernel.org/pub/linux/kernel/v2.6/ so that I wouldn't have to worry
> about distribution changes when reporting the bug here. I just recompiled the
> source and verified that it is still affected even with the newest firmware.

Thank you for going to that trouble to narrow it down, thank you for
confirming, and I apologize for shedding doubt on your finding.

It appears that there's something else involved here, which I know nothing
about as yet; perhaps an earlier change in block layer handling of discard.

Although it's just history now, I ought to investigate once my Vertex2
arrives - well, several weeks later, I won't have time immediately.

Please would you clarify one thing.  2.6.33.1 was the earliest kernel
you saw the slowdown on.  I assume from that that you tried 2.6.33 itself,
and it did not show the slowdown.  Or were you testing releases in some
other order? if so please let me know the latest without the slowdown.

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
